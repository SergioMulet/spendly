import Foundation
import Testing
@testable import Spendly

struct StubAuthenticator: AuthenticationService {
    let succeeds: Bool

    func authenticate(reason: String) async -> Bool { succeeds }
}

struct FaceIDLockTests {
    private func lockDefaults(enabled: Bool) -> UserDefaults {
        let defaults = TestDefaults.make()
        defaults.set(enabled, forKey: "faceIDLock")
        return defaults
    }

    @Test func theAppStartsLockedOnlyWhenTheLockIsOn() {
        #expect(AppLockViewModel(defaults: lockDefaults(enabled: true), authenticator: StubAuthenticator(succeeds: true)).isLocked)
        #expect(!AppLockViewModel(defaults: lockDefaults(enabled: false), authenticator: StubAuthenticator(succeeds: true)).isLocked)
    }

    @Test func goingToTheBackgroundLocksTheAppOnlyWhenTheLockIsOn() async {
        let on = AppLockViewModel(defaults: lockDefaults(enabled: true), authenticator: StubAuthenticator(succeeds: true))
        await on.unlock()
        on.appDidEnterBackground()
        #expect(on.isLocked)

        let off = AppLockViewModel(defaults: lockDefaults(enabled: false), authenticator: StubAuthenticator(succeeds: true))
        off.appDidEnterBackground()
        #expect(!off.isLocked)
    }

    @Test func unlockingWithTheRightFaceOpensTheApp() async {
        let lock = AppLockViewModel(defaults: lockDefaults(enabled: true), authenticator: StubAuthenticator(succeeds: true))

        await lock.unlock()

        #expect(!lock.isLocked)
    }

    @Test func aFailedAuthenticationKeepsTheAppLocked() async {
        let lock = AppLockViewModel(defaults: lockDefaults(enabled: true), authenticator: StubAuthenticator(succeeds: false))

        await lock.unlock()

        #expect(lock.isLocked)
    }

    @Test func turningTheLockOnKeepsItWhenTheUserAuthenticates() async {
        let defaults = TestDefaults.make()
        let settings = SettingsViewModel(defaults: defaults, synchronizer: StubSynchronizer(), authenticator: StubAuthenticator(succeeds: true))

        settings.faceIDLock = true
        await settings.faceIDLockChanged()

        #expect(settings.faceIDLock)
        #expect(defaults.bool(forKey: "faceIDLock"))
    }

    @Test func turningTheLockOnWithoutAuthenticatingGoesBackOff() async {
        let defaults = TestDefaults.make()
        let settings = SettingsViewModel(defaults: defaults, synchronizer: StubSynchronizer(), authenticator: StubAuthenticator(succeeds: false))

        settings.faceIDLock = true
        await settings.faceIDLockChanged()

        #expect(!settings.faceIDLock)
        #expect(!defaults.bool(forKey: "faceIDLock"))
    }
}
