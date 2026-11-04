import Foundation
import Observation

@MainActor
@Observable
final class AppLockViewModel {
    private(set) var isLocked: Bool
    
    private let defaults: UserDefaults
    private let authenticator: AuthenticationService
    private var isAuthenticating = false
    
    init(defaults: UserDefaults = .standard, authenticator: AuthenticationService? = nil){
        self.defaults = defaults
        self.authenticator = authenticator ?? FaceIDService()
        isLocked = defaults.bool(forKey: "faceIDLock")
    }
    
    func appDidEnterBackground(){
        if defaults.bool(forKey: "faceIDLock") { isLocked = true }
    }
    
    func unlock() async {
        guard isLocked, !isAuthenticating else { return }
        isAuthenticating = true
        defer { isAuthenticating = false }
        isLocked = !(await authenticator.authenticate(reason: String(localized: "Unlock Spendly")))
    }
}
