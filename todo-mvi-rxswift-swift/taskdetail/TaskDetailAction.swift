//
//  TaskDetailAction.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 03/12/2021.
//

import Foundation

enum EnumTaskDetailAction: MviAction, RawRepresentable {
    
    typealias RawValue = TaskDetailAction
    
    init?(rawValue: TaskDetailAction) {
        switch rawValue {
        case is TaskDetailAction.PopulateTaskAction:
            self = .PopulateTaskAction(TaskDetailAction.PopulateTaskAction(taskId: (rawValue as! TaskDetailAction.PopulateTaskAction).taskId))
        case is TaskDetailAction.DeleteTaskAction :
            self = .DeleteTaskAction(TaskDetailAction.DeleteTaskAction(taskId: (rawValue as! TaskDetailAction.DeleteTaskAction).taskId))
        case is TaskDetailAction.ActivateTaskAction :
            self = .ActivateTaskAction(TaskDetailAction.ActivateTaskAction(taskId: (rawValue as! TaskDetailAction.ActivateTaskAction).taskId))
        case is TaskDetailAction.CompleteTaskAction :
            self = .CompleteTaskAction(TaskDetailAction.CompleteTaskAction(taskId: (rawValue as! TaskDetailAction.CompleteTaskAction).taskId))
        default:
            self = .PopulateTaskAction(TaskDetailAction.PopulateTaskAction(taskId: (rawValue as! TaskDetailAction.PopulateTaskAction).taskId))
        }
    }
    
    var rawValue: TaskDetailAction {
        switch self {
        case .PopulateTaskAction (let action):
            return TaskDetailAction.PopulateTaskAction(taskId: action.taskId)
        case .DeleteTaskAction (let action):
            return TaskDetailAction.DeleteTaskAction(taskId: action.taskId)
        case .ActivateTaskAction (let action):
            return TaskDetailAction.ActivateTaskAction(taskId: action.taskId)
        case .CompleteTaskAction (let action):
            return TaskDetailAction.CompleteTaskAction(taskId: action.taskId)
        }
    }
    
    case PopulateTaskAction(TaskDetailAction.PopulateTaskAction)
    case DeleteTaskAction(TaskDetailAction.DeleteTaskAction)
    case ActivateTaskAction(TaskDetailAction.ActivateTaskAction)
    case CompleteTaskAction(TaskDetailAction.CompleteTaskAction)
}

class TaskDetailAction: MviAction {}

extension TaskDetailAction {
    
    class PopulateTaskAction: TaskDetailAction {
        let taskId: String
        
        init(taskId: String) {
            self.taskId = taskId
        }
    }
    
    class DeleteTaskAction: TaskDetailAction {
        let taskId: String
        
        init(taskId: String) {
            self.taskId = taskId
        }
    }
    
    class ActivateTaskAction: TaskDetailAction {
        let taskId: String
        
        init(taskId: String) {
            self.taskId = taskId
        }
    }
    
    class CompleteTaskAction: TaskDetailAction {
        let taskId: String
        
        init(taskId: String) {
            self.taskId = taskId
        }
    }
}
