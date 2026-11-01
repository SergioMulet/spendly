import SwiftUI

struct ExpenseView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ExpenseViewModel
    
    init(date: Date) {
        _viewModel = State(initialValue: ExpenseViewModel(date: date))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $viewModel.title)
                    TextField("Amount", value: $viewModel.amount, format: .currency(code: "EUR"))
                        .keyboardType(.decimalPad)
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
            .navigationTitle("New expense")
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
