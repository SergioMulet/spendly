import SwiftUI

// TODO: Improve calendar
struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        List {
            Section {
                ExpenseCalendarView(
                    selectedDate: $viewModel.selectedDate,
                    visibleMonth: $viewModel.visibleMonth,
                    dailyTotals: viewModel.dailyTotals,
                    currencyCode: viewModel.currencyCode
                )
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
                            Button {
                                viewModel.expenseToEdit = expense
                            } label: {
                                HStack {
                                    LabeledContent {
                                        Text(expense.amount, format: .currency(code: viewModel.currencyCode))
                                    } label: {
                                        Text(expense.title)
                                        Text(expense.date, format: .dateTime.day().month())
                                    }
                                    Image(systemName: "chevron.right")
                                        .font(.footnote.weight(.semibold))
                                        .foregroundStyle(.tertiary)
                                }
                            }
                            .foregroundStyle(.primary)
                            .font(.subheadline)
                            .swipeActions {
                                Button(role: .destructive) {
                                    Task { await viewModel.delete(expense) }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(group.category.title)
                            Spacer()
                            Text(group.total, format: .currency(code: viewModel.currencyCode))
                        }
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            Task { await viewModel.delete(group) }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            } header: {
                Text("\(Text(viewModel.visibleMonthDate, format: .dateTime.month(.wide))) total expenses: \(Text(viewModel.monthTotal, format: .currency(code: viewModel.currencyCode)))")
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
        .sheet(item: $viewModel.expenseToEdit, onDismiss: {
            Task { await viewModel.loadExpenses() }
        }) { expense in
            ExpenseView(expense: expense)
        }
        .task(id: viewModel.visibleMonth) {
            await viewModel.refresh()
        }
        .onChange(of: scenePhase) { _, phase in
            Task { await viewModel.refresh(isActive: phase == .active) }
        }
        .alert(Text(viewModel.errorTitle), isPresented: $viewModel.showingError) {
            Button("OK", role: .cancel) {}
        }
    }
}

#Preview {
    HomeView()
}
