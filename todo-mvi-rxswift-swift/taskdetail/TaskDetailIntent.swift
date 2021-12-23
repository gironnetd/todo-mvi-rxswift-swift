//
//  TaskDetailIntent.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 03/12/2021.
//

import Foundation

enum EnumTaskDetailIntent: MviIntent, RawRepresentable {
    
    typealias RawValue = TaskDetailIntent
    
    init?(rawValue: TaskDetailIntent) {
        switch rawValue {
        case is TaskDetailIntent.InitialIntent :
            self = .InitialIntent(TaskDetailIntent.InitialIntent(taskId: (rawValue as! TaskDetailIntent.InitialIntent).taskId))
        case is TaskDetailIntent.DeleteTaskIntent:
            self = .DeleteTask(TaskDetailIntent.DeleteTaskIntent(taskId: (rawValue as! TaskDetailIntent.DeleteTaskIntent).taskId))
        case is TaskDetailIntent.ActivateTaskIntent:
            self = .ActivateTaskIntent(TaskDetailIntent.ActivateTaskIntent(taskId: (rawValue as! TaskDetailIntent.ActivateTaskIntent).taskId))
        case is TaskDetailIntent.CompleteTaskIntent:
            self = .CompleteTaskIntent(TaskDetailIntent.CompleteTaskIntent(taskId: (rawValue as! TaskDetailIntent.CompleteTaskIntent).taskId))
        default:
            self = .InitialIntent(TaskDetailIntent.InitialIntent(taskId: (rawValue as! TaskDetailIntent.InitialIntent).taskId))
        }
    }
    
    var rawValue: TaskDetailIntent {
        switch self {
        case .InitialIntent (let intent):
            return TaskDetailIntent.InitialIntent(taskId: intent.taskId)
        case .DeleteTask (let intent):
            return TaskDetailIntent.DeleteTaskIntent(taskId: intent.taskId)
        case .ActivateTaskIntent (let intent):
            return TaskDetailIntent.ActivateTaskIntent(taskId: intent.taskId)
        case .CompleteTaskIntent (let intent):
            return TaskDetailIntent.CompleteTaskIntent(taskId: intent.taskId)
        }
    }
        
    case InitialIntent(TaskDetailIntent.InitialIntent)
    case DeleteTask(TaskDetailIntent.DeleteTaskIntent)
    case ActivateTaskIntent(TaskDetailIntent.ActivateTaskIntent)
    case CompleteTaskIntent(TaskDetailIntent.CompleteTaskIntent)
}

class TaskDetailIntent {}

extension TaskDetailIntent {
    
    class InitialIntent: TaskDetailIntent {
        let taskId: String
        
        init(taskId: String) {
            self.taskId = taskId
        }
    }

    class DeleteTaskIntent: TaskDetailIntent {
        let taskId: String
        
        init(taskId: String) {
            self.taskId = taskId
        }
    }

    class ActivateTaskIntent: TaskDetailIntent {
        let taskId: String
        
        init(taskId: String) {
            self.taskId = taskId
        }
    }

    class CompleteTaskIntent: TaskDetailIntent {
        let taskId: String
        
        init(taskId: String) {
            self.taskId = taskId
        }
    }
}

