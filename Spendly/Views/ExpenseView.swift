import SwiftUI

struct ExpenseView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ExpenseViewModel
    @FocusState private var amountIsFocused: Bool
    @State private var amountSelection: TextSelection?
    
    init(date: Date) {
        _viewModel = State(initialValue: ExpenseViewModel(date: date))
    }
    
    init(expense: Expense) {
        _viewModel = State(initialValue: ExpenseViewModel(expense: expense))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $viewModel.title)
                    TextField("Amount", text: $viewModel.amountText, selection: $amountSelection)
                        .keyboardType(.decimalPad)
                        .focused($amountIsFocused)
                        .onChange(of: amountIsFocused) { _, isFocused in
                            guard isFocused else { return }
                            amountSelection = TextSelection(range: viewModel.amountText.startIndex..<viewModel.amountText.endIndex)
                        }
                    Picker("Category", selection: $viewModel.category) {
                        ForEach(Category.allCases, id: \.self) { category in
                            Text(category.title).tag(category)
                        }
                    }
                }
                Section {
                    DatePicker("Date", selection: $viewModel.date, displayedComponents: .date)
                }
                Section {
                    Button("Save") {
                        Task { await viewModel.save() }
                    }
                    .disabled(!viewModel.canSave)
                    Button("Cancel", role: .cancel) { dismiss() }
                }
            }
            .navigationTitle(Text(viewModel.screenTitle))
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: viewModel.didSave) { dismiss() }
            .alert("Could not save expense", isPresented: $viewModel.showingError) {
                Button("OK", role: .cancel) {}
            }
        }
    }
}

#Preview {
    ExpenseView(date: .now)
}
