import SwiftUI
import Playgrounds

// TODO: Improve calendar and add list of expenses
struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    
    var body: some View {
        VStack{
            DatePicker("Select a date", selection: $viewModel.selectedDate, displayedComponents: .date).datePickerStyle(.graphical).padding()
            Spacer()
        }
        List{
            
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
        .sheet(isPresented: $viewModel.showingAddExpense){
            ExpenseView(date: viewModel.selectedDate)
        }
        
    }
}

#Preview {
    HomeView()
}
