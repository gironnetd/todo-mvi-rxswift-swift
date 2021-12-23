//
//  TasksIntent.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 03/12/2021.
//

import Foundation

enum EnumTasksIntent: MviIntent, RawRepresentable {
    
    typealias RawValue = TasksIntent
    
    init?(rawValue: TasksIntent) {
        switch rawValue {
        case is TasksIntent.InitialIntent:
            self = .InitialIntent
        case is TasksIntent.RefreshIntent:
            self = .RefreshIntent(TasksIntent.RefreshIntent(forceUpdate: (rawValue as! TasksIntent.RefreshIntent).forceUpdate))
        case is TasksIntent.ActivateTaskIntent:
            self = .ActivateTaskIntent(TasksIntent.ActivateTaskIntent(task: (rawValue as! TasksIntent.ActivateTaskIntent).task))
        case is TasksIntent.CompleteTaskIntent:
            self = .CompleteTaskIntent(TasksIntent.CompleteTaskIntent(task: (rawValue as! TasksIntent.CompleteTaskIntent).task))
        case is TasksIntent.ClearCompletedTasksIntent:
            self = .ClearCompletedTasksIntent
        case is TasksIntent.ChangeFilterIntent:
            self = .ChangeFilterIntent(TasksIntent.ChangeFilterIntent(filterType: (rawValue as! TasksIntent.ChangeFilterIntent).filterType))
        default:
            self = .InitialIntent
        }
    }
    
    var rawValue: TasksIntent {
        switch self {
        case .InitialIntent:
            return TasksIntent.InitialIntent()
        case .RefreshIntent(let intent):
            return TasksIntent.RefreshIntent(forceUpdate: intent.forceUpdate)
        case .ActivateTaskIntent(let intent):
            return TasksIntent.ActivateTaskIntent(task: intent.task)
        case .CompleteTaskIntent(let intent):
            return TasksIntent.CompleteTaskIntent(task: intent.task)
        case .ClearCompletedTasksIntent:
            return TasksIntent.ClearCompletedTasksIntent()
        case .ChangeFilterIntent(let intent):
            return TasksIntent.ChangeFilterIntent(filterType: intent.filterType)
        }
    }
        
    case InitialIntent
    case RefreshIntent(TasksIntent.RefreshIntent)
    case ActivateTaskIntent(TasksIntent.ActivateTaskIntent)
    case CompleteTaskIntent(TasksIntent.CompleteTaskIntent)
    case ClearCompletedTasksIntent
    case ChangeFilterIntent(TasksIntent.ChangeFilterIntent)
}

class TasksIntent {}

extension TasksIntent {
    
    class InitialIntent: TasksIntent {}

    class RefreshIntent: TasksIntent {
        let forceUpdate: Bool
        
        init(forceUpdate: Bool) {
            self.forceUpdate = forceUpdate
        }
    }

    class ActivateTaskIntent: TasksIntent {
        let task: Task
        
        init(task: Task) {
            self.task = task
        }
    }

    class CompleteTaskIntent: TasksIntent {
        let task: Task
        
        init(task: Task) {
            self.task = task
        }
    }

    class ClearCompletedTasksIntent: TasksIntent { }

    class ChangeFilterIntent: TasksIntent {
        var filterType: TasksFilterType
    
        init(filterType: TasksFilterType) {
            self.filterType = filterType
        }
    }
}
