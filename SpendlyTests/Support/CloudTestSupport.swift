import Foundation
@testable import Spendly

enum TestDefaults {
    /// A throwaway UserDefaults, so tests never read or change the real settings.
    static func make() -> UserDefaults {
        let name = "SpendlyTests." + UUID().uuidString
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return defaults
    }
}

/// iCloud in memory. It remembers when each expense changed, so it can answer "what is new since this marker".
actor FakeCloudStore: CloudExpenseStore {
    private(set) var records: [UUID: Expense] = [:]
    private(set) var saveCalls = 0
    private var version = 0
    private var changedAt: [UUID: Int] = [:]
    private var deletedAt: [UUID: Int] = [:]
    private var accountAvailable = true
    private var failsOnWrite = false
    
    func setAccountAvailable(_ available: Bool) { accountAvailable = available }
    func setFailsOnWrite(_ fails: Bool) { failsOnWrite = fails }
    
    func prepare() async throws -> String {
        guard accountAvailable else { throw CloudSyncError.accountUnavailable }
        return "account-1"
    }
    
    func fetchChanges(since token: Data?) async throws -> CloudChanges {
        let since = token.flatMap { String(data: $0, encoding: .utf8) }.flatMap(Int.init) ?? 0
        return CloudChanges(
            expenses: records.values.filter { changedAt[$0.id, default: 0] > since },
            deletedIDs: deletedAt.filter { $0.value > since }.map(\.key),
            token: Data(String(version).utf8)
        )
    }
    
    func save(_ expenses: [Expense]) async throws {
        if failsOnWrite { throw URLError(.notConnectedToInternet) }
        saveCalls += 1
        for expense in expenses {
            version += 1
            records[expense.id] = expense
            changedAt[expense.id] = version
            deletedAt[expense.id] = nil
        }
    }
    
    func delete(ids: [UUID]) async throws {
        if failsOnWrite { throw URLError(.notConnectedToInternet) }
        for id in ids where records[id] != nil {
            version += 1
            records[id] = nil
            changedAt[id] = nil
            deletedAt[id] = version
        }
    }
}

actor StubSynchronizer: ExpenseSyncing {
    private let error: Error?
    private(set) var calls = 0
    
    init(error: Error? = nil) {
        self.error = error
    }
    
    func sync() async throws {
        calls += 1
        if let error { throw error }
    }
}
