import SwiftUI

struct TaskListView: View {
    let taskVM: TaskViewModel
    @State private var newTaskTitle = ""
    @State private var isAddingTask = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("오늘 할 일")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)

            if taskVM.todayTasks.isEmpty && !isAddingTask {
                Text("오늘 예정된 일정이 없습니다")
                    .font(.caption)
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
                }
                .frame(maxHeight: 200)
            }

            // Add task
            if isAddingTask {
                HStack {
                    TextField("할 일 입력", text: $newTaskTitle)
                        .textFieldStyle(.plain)
                        .font(.system(size: 13))
                        .onSubmit {
                            taskVM.addTask(title: newTaskTitle)
                            newTaskTitle = ""
                            isAddingTask = false
                        }

                    Button("취소") {
                        newTaskTitle = ""
                        isAddingTask = false
                    }
                    .buttonStyle(.plain)
                    .font(.caption)
                }
                .padding(.horizontal, 12)
            } else {
                Button(action: { isAddingTask = true }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("할 일 추가")
                    }
                    .font(.caption)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 12)
            }
        }
        .padding(.bottom, 8)
    }
}
