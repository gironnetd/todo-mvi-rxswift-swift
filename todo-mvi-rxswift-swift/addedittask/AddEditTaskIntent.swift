//
//  AddEditTaskIntent.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 03/12/2021.
//

import Foundation

enum EnumAddEditTaskIntent: MviIntent, RawRepresentable {
    
    typealias RawValue = AddEditTaskIntent
    
    init?(rawValue: AddEditTaskIntent) {
        switch rawValue {
        case is AddEditTaskIntent.InitialIntent:
            self = .InitialIntent(AddEditTaskIntent.InitialIntent(taskId: (rawValue as! AddEditTaskIntent.InitialIntent).taskId))
        case is AddEditTaskIntent.SaveTaskIntent:
            self = .SaveTask(AddEditTaskIntent.SaveTaskIntent(
                                    taskId: (rawValue as! AddEditTaskIntent.SaveTaskIntent).taskId,
                                    title: (rawValue as! AddEditTaskIntent.SaveTaskIntent).title,
                                    description: (rawValue as! AddEditTaskIntent.SaveTaskIntent).description))
        default:
            self = .InitialIntent(AddEditTaskIntent.InitialIntent(taskId: (rawValue as! AddEditTaskIntent.InitialIntent).taskId))
        }
    }
    
    var rawValue: AddEditTaskIntent {
        switch self {
        case .InitialIntent (let intent):
            return AddEditTaskIntent.InitialIntent(taskId: intent.taskId)
        case .SaveTask (let intent):
            return AddEditTaskIntent.SaveTaskIntent(taskId: intent.taskId, title: intent.title, description: intent.description)
        }
    }
        
    case InitialIntent(AddEditTaskIntent.InitialIntent)
    case SaveTask(AddEditTaskIntent.SaveTaskIntent)
}

class AddEditTaskIntent {}

extension AddEditTaskIntent {
    
    class InitialIntent: AddEditTaskIntent {
        let taskId: String?
        
        init(taskId: String?) {
            self.taskId = taskId
        }
    }
    
    class SaveTaskIntent: AddEditTaskIntent {
        let taskId: String?
        let title: String
        let description: String
        
        init(taskId: String?, title: String, description: String) {
            self.taskId = taskId
            self.title = title
            self.description = description
        }
    }
}
