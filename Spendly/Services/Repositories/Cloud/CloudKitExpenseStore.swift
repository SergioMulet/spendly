import CloudKit
import Foundation

/// Stores expenses in the user's private iCloud database, in a zone of its own so changes can be fetched incrementally.
actor CloudKitExpenseStore: CloudExpenseStore {
    static let shared = CloudKitExpenseStore()
    
    private let zoneID = CKRecordZone.ID(zoneName: "Expenses", ownerName: CKCurrentUserDefaultName)
    /// CloudKit accepts at most 400 records per request.
    private let batchSize = 200
    /// Created on first use: asking for the container without the iCloud capability crashes the app,
    /// so nothing here runs while the "iCloud sync" setting has never been turned on.
    private var cachedContainer: CKContainer?
    private var zoneIsReady = false
    
    private var container: CKContainer {
        let container = cachedContainer ?? CKContainer.default()
        cachedContainer = container
        return container
    }
    
    func prepare() async throws -> String {
        guard try await container.accountStatus() == .available else { throw CloudSyncError.accountUnavailable }
        try await createZoneIfNeeded()
        return try await container.userRecordID().recordName
    }
    
    func fetchChanges(since tokenData: Data?) async throws -> CloudChanges {
        try await createZoneIfNeeded()
        var token = try tokenData.flatMap { try NSKeyedUnarchiver.unarchivedObject(ofClass: CKServerChangeToken.self, from: $0) }
        var changes = CloudChanges()
        var moreComing = true
        
        while moreComing {
            do {
                let result = try await container.privateCloudDatabase.recordZoneChanges(inZoneWith: zoneID, since: token)
                for (_, modification) in result.modificationResultsByID {
                    if let record = try? modification.get().record, let expense = Expense(record) {
                        changes.expenses.append(expense)
                    }
                }
                changes.deletedIDs += result.deletions.compactMap { UUID(uuidString: $0.recordID.recordName) }
                token = result.changeToken
                moreComing = result.moreComing
            } catch let error as CKError where error.code == .changeTokenExpired {
                // iCloud no longer knows that marker: start again and download everything.
                token = nil
                changes = CloudChanges()
            }
        }
        changes.token = try token.map { try NSKeyedArchiver.archivedData(withRootObject: $0, requiringSecureCoding: true) }
        return changes
    }
    
    func save(_ expenses: [Expense]) async throws {
        try await createZoneIfNeeded()
        for start in stride(from: 0, to: expenses.count, by: batchSize) {
            let records = expenses[start..<min(start + batchSize, expenses.count)].map { $0.record(in: zoneID) }
            let result = try await container.privateCloudDatabase.modifyRecords(saving: records, deleting: [], savePolicy: .allKeys)
            for (_, saved) in result.saveResults {
                _ = try saved.get()
            }
        }
    }
    
    func delete(ids: [UUID]) async throws {
        try await createZoneIfNeeded()
        for start in stride(from: 0, to: ids.count, by: batchSize) {
            let recordIDs = ids[start..<min(start + batchSize, ids.count)].map { CKRecord.ID(recordName: $0.uuidString, zoneID: zoneID) }
            let result = try await container.privateCloudDatabase.modifyRecords(saving: [], deleting: recordIDs)
            for (_, deleted) in result.deleteResults {
                do {
                    try deleted.get()
                } catch let error as CKError where error.code == .unknownItem {
                    // It was already gone, which is what we wanted.
                }
            }
        }
    }
    
    private func createZoneIfNeeded() async throws {
        guard !zoneIsReady else { return }
        _ = try await container.privateCloudDatabase.modifyRecordZones(saving: [CKRecordZone(zoneID: zoneID)], deleting: [])
        zoneIsReady = true
    }
}

nonisolated private extension Expense {
    static let recordType = "Expense"
    
    init?(_ record: CKRecord) {
        guard let id = UUID(uuidString: record.recordID.recordName),
              let title = record["title"] as? String,
              let amount = record["amount"] as? Double,
              let date = record["date"] as? Date,
              let category = (record["category"] as? String).flatMap(Category.init),
              let updatedAt = record["updatedAt"] as? Date else { return nil }
        self.init(id: id, title: title, amount: amount, date: date, category: category, updatedAt: updatedAt)
    }
    
    func record(in zoneID: CKRecordZone.ID) -> CKRecord {
        let record = CKRecord(recordType: Self.recordType, recordID: CKRecord.ID(recordName: id.uuidString, zoneID: zoneID))
        record["title"] = title
        record["amount"] = amount
        record["date"] = date
        record["category"] = category.rawValue
        record["updatedAt"] = updatedAt
        return record
    }
}
