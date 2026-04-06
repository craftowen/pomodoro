import SwiftUI

struct TaskRowView: View {
    let task: TaskItem
    let onSelect: () -> Void
    let onComplete: () -> Void
    let onDelete: () -> Void

    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 8) {
            selectionIndicator
                .accessibilityLabel(task.isSelected ? String(localized: "a11y.deselect") : String(localized: "a11y.select"))

            if let timeLabel = task.timeLabel {
                Text(timeLabel)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Text(task.title)
                .font(.system(size: 13, weight: task.isSelected ? .medium : .regular, design: .rounded))
                .strikethrough(task.isCompleted)
                .foregroundStyle(titleColor)
                .lineLimit(task.isSelected ? nil : 1)
                .help(task.title)

            Spacer(minLength: 0)

            if task.source == .googleCalendar || task.source == .systemCalendar {
                Image(systemName: "calendar")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
            }

            Button(action: onComplete) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "checkmark.circle")
                    .font(.system(size: 14))
                    .foregroundStyle(task.isCompleted ? AnyShapeStyle(Color.pomodoroBreak) : AnyShapeStyle(.secondary))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(task.isCompleted ? String(localized: "a11y.undoComplete") : String(localized: "a11y.complete"))
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(rowBackground)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .onHover { isHovered = $0 }
        .contentShape(Rectangle())
        .onTapGesture(perform: onSelect)
        .contextMenu {
            if task.source == .manual {
                Button(String(localized: "delete"), role: .destructive, action: onDelete)
            }
        }
    }

    private var selectionIndicator: some View {
        ZStack {
            Circle()
                .stroke(task.isSelected ? Color.pomodoroFocus : Color.gray.opacity(0.3), lineWidth: 1.5)
                .frame(width: 14, height: 14)

            if task.isSelected {
                Circle()
                    .fill(Color.pomodoroFocus)
                    .frame(width: 6, height: 6)
            }

            if task.isCompleted {
                Image(systemName: "checkmark")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(Color.pomodoroBreak)
            }
        }
        .animation(.easeOut(duration: 0.15), value: task.isSelected)
    }

    private var rowBackground: some View {
        Group {
            if task.isSelected {
                Color.pomodoroFocus.opacity(0.08)
            } else if isHovered {
                Color.primary.opacity(0.03)
            } else {
                Color.clear
            }
        }
        .animation(.easeOut(duration: 0.15), value: isHovered)
        .animation(.easeOut(duration: 0.15), value: task.isSelected)
    }

    private var titleColor: some ShapeStyle {
        if task.isCompleted { return AnyShapeStyle(.secondary) }
        return AnyShapeStyle(.primary)
    }
}
