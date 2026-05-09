import SwiftUI

struct StatsView: View {
    
    let xp: Int
    let sessions: Int
    let streak: Int
    
    var body: some View {
        VStack(spacing: 25) {
            
            Text("Your Stats")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("XP: \(xp)")
                .font(.title2)
            
            Text("Sessions Completed: \(sessions)")
                .font(.title2)
            
            Text("Current Streak: \(streak)")
                .font(.title2)
            
            Spacer()
        }
        .padding()
    }
}
