import SwiftUI

struct TaskRowView: View {
    let task: TaskItem
    let onSelect: () -> Void
    let onComplete: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            // Selection indicator
            Image(systemName: task.isSelected ? "largecircle.fill.circle" : "circle")
                .foregroundStyle(task.isSelected ? Color.accentColor : Color.secondary)
                .font(.system(size: 14))
                .onTapGesture(perform: onSelect)

            // Time label
            if let timeLabel = task.timeLabel {
                Text(timeLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: 40, alignment: .leading)
            }

            // Title
            Text(task.title)
                .font(.system(size: 13))
                .strikethrough(task.isCompleted)
                .foregroundStyle(task.isCompleted ? .secondary : .primary)
                .lineLimit(1)

            Spacer()

            // Source label
            if task.source == .googleCalendar || task.source == .systemCalendar {
                Image(systemName: "calendar")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            // Complete button
            Button(action: onComplete) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "checkmark.circle")
                    .foregroundStyle(task.isCompleted ? .green : .secondary)
                    .font(.system(size: 14))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 4)
        .contentShape(Rectangle())
        .contextMenu {
            if task.source == .manual {
                Button("삭제", role: .destructive, action: onDelete)
            }
        }
    }
}
