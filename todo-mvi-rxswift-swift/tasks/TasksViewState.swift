//
//  TasksViewState.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 03/12/2021.
//

import Foundation

struct TasksViewState : MviViewState {
    
    let isLoading: Bool
    let tasksFilterType: TasksFilterType
    let tasks: [Task]
    let error: Error?
    let uiNotification: UiNotification?
    
    enum UiNotification {
        case TASK_COMPLETE, TASK_ACTIVATED, COMPLETE_TASKS_CLEARED
    }
    
    static func idle() -> TasksViewState {
        return TasksViewState(
            isLoading: false,
            tasksFilterType: .ALL_TASKS,
            tasks: [],
            error: nil,
            uiNotification: nil
        )
    }
}

extension TasksViewState {

    func copy(isLoading: Bool? = nil, tasksFilterType: TasksFilterType? = nil, tasks: [Task]? = nil,
              error: Error? = nil, uiNotification: UiNotification? = nil) -> TasksViewState {
        TasksViewState(
            isLoading: isLoading ?? self.isLoading,
            tasksFilterType: tasksFilterType ?? self.tasksFilterType,
            tasks: tasks ?? self.tasks,
            error: error ?? self.error,
            uiNotification: uiNotification ?? .none
        )
    }
}

extension TasksViewState : Equatable {
    static func == (lhs: TasksViewState, rhs: TasksViewState) -> Bool {
        return
            lhs.isLoading == rhs.isLoading &&
            lhs.tasksFilterType == rhs.tasksFilterType &&
            lhs.tasks == rhs.tasks &&
            lhs.error?.localizedDescription == rhs.error?.localizedDescription &&
            lhs.uiNotification == rhs.uiNotification
    }
}
