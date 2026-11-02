import Foundation
import Testing
@testable import Spendly

struct ICloudSyncViewModelTests {
    @Test func iCloudSyncIsOffByDefault() {
        let settings = SettingsViewModel(defaults: TestDefaults.make(), synchronizer: StubSynchronizer())
        #expect(!settings.iCloudSync)
    }
    
    @Test(.disabled("iCloud sync is paused until the iCloud capability is available. Enable it again when SettingsViewModel.iCloudSyncChanged is restored.")) func turningItOnSyncsAndKeepsTheSwitchOn() async {
        let defaults = TestDefaults.make()
        let sync = StubSynchronizer()
        let settings = SettingsViewModel(defaults: defaults, synchronizer: sync)
        
        settings.iCloudSync = true
        await settings.iCloudSyncChanged()
        
        #expect(settings.iCloudSync)
        #expect(defaults.bool(forKey: CloudSyncSettings.key))
        #expect(await sync.calls == 1)
        #expect(!settings.showingError)
    }
    
    @Test(.disabled("iCloud sync is paused until the iCloud capability is available. Enable it again when SettingsViewModel.iCloudSyncChanged is restored.")) func withoutAnICloudAccountTheSwitchGoesBackOffAndExplainsWhy() async {
        let defaults = TestDefaults.make()
        let settings = SettingsViewModel(defaults: defaults, synchronizer: StubSynchronizer(error: CloudSyncError.accountUnavailable))
        
        settings.iCloudSync = true
        await settings.iCloudSyncChanged()
        
        #expect(!settings.iCloudSync)
        #expect(!defaults.bool(forKey: CloudSyncSettings.key))
        #expect(settings.showingError)
    }
    
    @Test(.disabled("iCloud sync is paused until the iCloud capability is available. Enable it again when SettingsViewModel.iCloudSyncChanged is restored.")) func anyOtherFailureAlsoTurnsTheSwitchOff() async {
        let settings = SettingsViewModel(defaults: TestDefaults.make(), synchronizer: StubSynchronizer(error: URLError(.notConnectedToInternet)))
        
        settings.iCloudSync = true
        await settings.iCloudSyncChanged()
        
        #expect(!settings.iCloudSync)
        #expect(settings.showingError)
    }
    
    @Test func whileICloudIsPausedTheSwitchCanNotBeTurnedOn() async {
        let defaults = TestDefaults.make()
        let sync = StubSynchronizer()
        let settings = SettingsViewModel(defaults: defaults, synchronizer: sync)
        
        settings.iCloudSync = true
        await settings.iCloudSyncChanged()
        
        #expect(!settings.iCloudSync)
        #expect(await sync.calls == 0)
    }
    
    @Test func theAppNeverSyncsWhenICloudIsNotAvailableEvenIfTheSettingIsStoredAsOn() {
        let defaults = TestDefaults.make()
        defaults.set(true, forKey: CloudSyncSettings.key)
        
        #expect(!CloudSyncSettings(defaults: defaults, isAvailable: false).isEnabled)
        #expect(CloudSyncSettings(defaults: defaults, isAvailable: true).isEnabled)
    }
    
    @Test func turningItOffDoesNotSync() async {
        let sync = StubSynchronizer()
        let settings = SettingsViewModel(defaults: TestDefaults.make(), synchronizer: sync)
        
        await settings.iCloudSyncChanged()
        
        #expect(await sync.calls == 0)
    }
    
    @Test func refreshingTheHomeSyncsOnlyWhileICloudIsOn() async throws {
        let store = try TestStore()
        let defaults = TestDefaults.make()
        let sync = StubSynchronizer()
        let home = HomeViewModel(repository: store.expenses, importer: store.importer, synchronizer: sync, syncSettings: CloudSyncSettings(defaults: defaults, isAvailable: true))
        
        await home.refresh()
        #expect(await sync.calls == 0)
        
        defaults.set(true, forKey: CloudSyncSettings.key)
        await home.refresh()
        #expect(await sync.calls == 1)
    }
    
    @Test func theHomeStillShowsLocalExpensesWhenTheSyncFails() async throws {
        let store = try TestStore()
        let defaults = TestDefaults.make()
        defaults.set(true, forKey: CloudSyncSettings.key)
        try await store.expenses.save(Expense(title: "Lunch", amount: 10, date: .now, category: .food))
        let home = HomeViewModel(repository: store.expenses, importer: store.importer, synchronizer: StubSynchronizer(error: CloudSyncError.accountUnavailable), syncSettings: CloudSyncSettings(defaults: defaults, isAvailable: true))
        
        await home.refresh()
        
        #expect(home.groups.map(\.category) == [.food])
        #expect(!home.showingError)
    }
}
