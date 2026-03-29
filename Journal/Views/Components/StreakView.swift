import SwiftUI

struct StreakView: View {
    let streak: Int
    let journaledToday: Bool

    var body: some View {
        HStack(spacing: 16) {
            // Flame + number
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("🔥")
                        .font(.title)
                    Text("\(streak)")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(streak > 0 ? Color.orange : Color.secondary)
                }
                Text(streak == 1 ? "day streak" : "day streak")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Today status badge
            VStack(alignment: .trailing, spacing: 4) {
                Image(systemName: journaledToday ? "checkmark.circle.fill" : "circle.dashed")
                    .font(.title2)
                    .foregroundStyle(journaledToday ? .green : .secondary)
                    .contentTransition(.symbolEffect(.replace))
                Text(journaledToday ? "Done today" : "Write today")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(journaledToday ? .green : .secondary)
            }
        }
        .padding(20)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20))
        .animation(.spring(duration: 0.4), value: streak)
        .animation(.spring(duration: 0.4), value: journaledToday)
    }
}

#Preview {
    VStack(spacing: 16) {
        StreakView(streak: 7, journaledToday: true)
        StreakView(streak: 3, journaledToday: false)
        StreakView(streak: 0, journaledToday: false)
    }
    .padding()
}
