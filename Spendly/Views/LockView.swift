import SwiftUI

struct LockView: View {
    let unlock: () -> Void
    var body: some View {
        ContentUnavailableView {
            Label("Spendly is locked", systemImage: "lock.fill")
        } actions: {
            Button("Unlock", action: unlock)
                .buttonStyle(.borderedProminent)
        }
        .background(.background)
    }
}
