import SwiftUI

// TODO: Improve calendar
struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        List {
            Section {
                DatePicker("Select a date", selection: $viewModel.selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
            }
            
            if viewModel.groups.isEmpty {
                Section {
                    ContentUnavailableView("No expenses this month", systemImage: "tray")
                }
            }
            Section {
                ForEach(viewModel.groups) { group in
                    DisclosureGroup {
                        ForEach(group.expenses) { expense in
                            LabeledContent {
                                Text(expense.amount, format: .currency(code: viewModel.currencyCode))
                            } label: {
                                Text(expense.title)
                                Text(expense.date, format: .dateTime.day().month())
                            }
                            .font(.subheadline)
                        }
                    } label: {
                        HStack {
                            Text(group.category.title)
                            Spacer()
                            Text(group.total, format: .currency(code: viewModel.currencyCode))
                        }
                    }
                }
            } header: {
                Text("\(Text(viewModel.selectedDate, format: .dateTime.month(.wide))) total expenses: \(Text(viewModel.monthTotal, format: .currency(code: viewModel.currencyCode)))")
                    .textCase(nil)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            Button {
                viewModel.showingAddExpense = true
            } label: {
                Image(systemName: "plus")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width:56, height:56)
                    .background(Color.accentColor, in: Circle())
            }
            .padding()
        }
        .sheet(isPresented: $viewModel.showingAddExpense, onDismiss: {
            Task { await viewModel.loadExpenses() }
        }) {
            ExpenseView(date: viewModel.selectedDate)
        }
        .task(id: viewModel.month) {
            await viewModel.refresh()
        }
        .onChange(of: scenePhase) { _, phase in
            Task { await viewModel.refresh(isActive: phase == .active) }
        }
        .alert("Could not load expenses", isPresented: $viewModel.showingError) {
            Button("OK", role: .cancel) {}
        }
    }
}

#Preview {
    HomeView()
}
