//
//  TasksAction.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 03/12/2021.
//

import Foundation

enum EnumTasksAction: MviAction, RawRepresentable {
    
    typealias RawValue = TasksAction
    
    init?(rawValue: TasksAction) {
        switch rawValue {
        case is TasksAction.LoadTasksAction:
            self = .LoadTasksAction(TasksAction.LoadTasksAction(forceUpdate: (rawValue as! TasksAction.LoadTasksAction).forceUpdate, filterType: (rawValue as! TasksAction.LoadTasksAction).filterType))
        case is TasksAction.ActivateTaskAction:
            self = .ActivateTaskAction(TasksAction.ActivateTaskAction(task: (rawValue as! TasksAction.ActivateTaskAction).task))
        case is TasksAction.CompleteTaskAction:
            self = .CompleteTaskAction(TasksAction.CompleteTaskAction(task: (rawValue as! TasksAction.CompleteTaskAction).task))
        case is TasksAction.ClearCompletedTasksAction:
            self = .ClearCompletedTasksAction
        default:
            self = .LoadTasksAction(TasksAction.LoadTasksAction(forceUpdate: true, filterType: .ALL_TASKS))
        }
    }
    
    var rawValue: TasksAction {
        switch self {
        case .LoadTasksAction (let action):
            return TasksAction.LoadTasksAction(forceUpdate: action.forceUpdate, filterType: action.filterType)
        case .ActivateTaskAction (let action):
            return TasksAction.ActivateTaskAction(task: action.task)
        case .CompleteTaskAction (let action):
            return TasksAction.CompleteTaskAction(task: action.task)
        case .ClearCompletedTasksAction:
            return TasksAction.ClearCompletedTasksAction()
        }
    }
    
    case LoadTasksAction(TasksAction.LoadTasksAction)
    case ActivateTaskAction(TasksAction.ActivateTaskAction)
    case CompleteTaskAction(TasksAction.CompleteTaskAction)
    case ClearCompletedTasksAction
}

class TasksAction: MviAction {}

extension TasksAction {
    
    class LoadTasksAction: TasksAction {
        let forceUpdate: Bool
        let filterType: TasksFilterType?
        
        init(forceUpdate: Bool, filterType: TasksFilterType?) {
            self.forceUpdate = forceUpdate
            self.filterType = filterType
        }
    }
    
    class ActivateTaskAction: TasksAction {
        let task: Task
        
        init(task: Task) {
            self.task = task
        }
    }
    
    class CompleteTaskAction: TasksAction {
        let task: Task
        
        init(task: Task) {
            self.task = task
        }
    }
    
    class ClearCompletedTasksAction: TasksAction {}
}
