import Foundation
import Observation

@Observable
final class HomeViewModel {
    var selectedDate = Date()
    var showingAddExpense = false
}
