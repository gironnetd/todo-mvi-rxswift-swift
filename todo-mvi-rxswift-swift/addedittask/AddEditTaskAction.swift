//
//  AddEditTaskAction.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 03/12/2021.
//

import Foundation

enum EnumAddEditTaskAction: MviAction, RawRepresentable {
    
    typealias RawValue = AddEditTaskAction
    
    init?(rawValue: AddEditTaskAction) {
        switch rawValue {
        case is AddEditTaskAction.PopulateTaskAction:
            self = .PopulateTaskAction(AddEditTaskAction.PopulateTaskAction(
                                        taskId: (rawValue as! AddEditTaskAction.PopulateTaskAction).taskId)
            )
        case is AddEditTaskAction.CreateTaskAction :
            self = .CreateTaskAction(AddEditTaskAction.CreateTaskAction(
                                        title: (rawValue as! AddEditTaskAction.CreateTaskAction).title,
                                        description: (rawValue as! AddEditTaskAction.CreateTaskAction).description))
        case is AddEditTaskAction.UpdateTaskAction :
            self = .UpdateTaskAction(AddEditTaskAction.UpdateTaskAction(
                taskId: (rawValue as! AddEditTaskAction.UpdateTaskAction).taskId,
                title: (rawValue as! AddEditTaskAction.UpdateTaskAction).title,
                description: (rawValue as! AddEditTaskAction.UpdateTaskAction).description)
            )
        case is AddEditTaskAction.SkipMe :
            self = .SkipMe
        default:
            self = .PopulateTaskAction(AddEditTaskAction.PopulateTaskAction(taskId: (rawValue as! AddEditTaskAction.PopulateTaskAction).taskId))
        }
    }
    
    var rawValue: AddEditTaskAction {
        switch self {
        case .PopulateTaskAction (let action):
            return AddEditTaskAction.PopulateTaskAction(taskId: action.taskId)
        case .CreateTaskAction (let action):
            return AddEditTaskAction.CreateTaskAction(
                title: action.title,
                description: action.description
                )
        case .UpdateTaskAction (let action):
            return AddEditTaskAction.UpdateTaskAction(
                taskId: action.taskId,
                title: action.title,
                description: action.description
                )
        case .SkipMe :
            return AddEditTaskAction.SkipMe()
        }
    }
    
    case PopulateTaskAction(AddEditTaskAction.PopulateTaskAction)
    case CreateTaskAction(AddEditTaskAction.CreateTaskAction)
    case UpdateTaskAction(AddEditTaskAction.UpdateTaskAction)
    case SkipMe
}

class AddEditTaskAction: MviAction {}

extension AddEditTaskAction {
    
    class PopulateTaskAction: AddEditTaskAction {
        let taskId: String
        
        init(taskId: String) {
            self.taskId = taskId
        }
    }
    
    class CreateTaskAction: AddEditTaskAction {
        let title: String
        let description: String
        
        init(title: String, description: String) {
            self.title = title
            self.description = description
        }
    }
    
    class UpdateTaskAction: AddEditTaskAction {
        let taskId: String
        let title: String
        let description: String
        
        init(taskId: String, title: String, description: String) {
            self.taskId = taskId
            self.title = title
            self.description = description
        }
    }
    
    class SkipMe : AddEditTaskAction {}
}

