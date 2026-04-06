import SwiftUI

struct TaskListView: View {
    let taskVM: TaskViewModel
    @State private var newTaskTitle = ""
    @State private var isAddingTask = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(String(localized: "today.tasks"))
                .font(.system(size: 9, weight: .semibold, design: .rounded))
                .foregroundStyle(.quaternary)
                .textCase(.uppercase)
                .tracking(1)
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 6)

            if taskVM.todayTasks.isEmpty && !isAddingTask {
                Text(String(localized: "no.tasks"))
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(taskVM.todayTasks) { task in
                            TaskRowView(
                                task: task,
                                onSelect: { taskVM.toggleSelection(task) },
                                onComplete: { taskVM.toggleCompletion(task) },
                                onDelete: { taskVM.deleteTask(task) }
                            )
                        }
                    }
                    .padding(.horizontal, 8)
                }
                .frame(maxHeight: 200)
            }

            if isAddingTask {
                HStack(spacing: 8) {
                    TextField(String(localized: "task.placeholder"), text: $newTaskTitle)
                        .textFieldStyle(.plain)
                        .font(.system(size: 11, design: .rounded))
                        .onSubmit {
                            taskVM.addTask(title: newTaskTitle)
                            newTaskTitle = ""
                            isAddingTask = false
                        }

                    Button(String(localized: "cancel")) {
                        newTaskTitle = ""
                        isAddingTask = false
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 10, design: .rounded))
                    .foregroundStyle(.tertiary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
            } else {
                Button(action: { isAddingTask = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 9))
                        Text(String(localized: "add"))
                            .font(.system(size: 10, design: .rounded))
                    }
                    .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
            }
        }
    }
}
