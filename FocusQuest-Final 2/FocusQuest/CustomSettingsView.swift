import SwiftUI

struct CustomSettingsView: View {
    
    @Binding var pomodoroLength: Int
    @Binding var shortBreakLength: Int
    @Binding var longBreakLength: Int
    
    var onSave: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
        ZStack {
            Image("background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
        }
        VStack(spacing: 20) {
            
            HStack {
                Text("Custom Timer")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            
            HStack {
                Text("Pomodoro")
                Spacer()
                TextField("Minutes", value: $pomodoroLength, format: .number)
                    .frame(width: 80)
                    .textFieldStyle(.roundedBorder)
            }
            
            HStack {
                Text("Short Break")
                Spacer()
                TextField("Minutes", value: $shortBreakLength, format: .number)
                    .frame(width: 80)
                    .textFieldStyle(.roundedBorder)
            }
            
            HStack {
                Text("Long Break")
                Spacer()
                TextField("Minutes", value: $longBreakLength, format: .number)
                    .frame(width: 80)
                    .textFieldStyle(.roundedBorder)
            }
            
            Spacer()
            
            Button("Save") {
                onSave()
                dismiss()
            }
            .padding()
            .frame(width: 120)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .frame(width: 300, height: 300)
    }
}
