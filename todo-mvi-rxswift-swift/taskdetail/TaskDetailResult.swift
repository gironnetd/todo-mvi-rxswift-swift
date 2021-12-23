//
//  TaskDetailResult.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 03/12/2021.
//

import Foundation

enum EnumTaskDetailResult: MviResult, RawRepresentable {
    
    typealias RawValue = TaskDetailResult
    
    init?(rawValue: TaskDetailResult) {
        switch rawValue.result {
        
        case let rawValue as TaskDetailResult.PopulateTaskResult :
            switch rawValue.rawValue {
            case let rawValue as TaskDetailResult.PopulateTaskResult.RawValue.Success:
                self = .PopulateTaskResult(.Success(.Success(task: rawValue.task))!)
            case let rawValue as TaskDetailResult.PopulateTaskResult.RawValue.Failure:
                self = .PopulateTaskResult(.Failure(.Failure(error: rawValue.error)))
            case is TaskDetailResult.PopulateTaskResult.RawValue.InFlight:
                self = .PopulateTaskResult(.InFlight)
            default:
                self = .PopulateTaskResult(.InFlight)
            }
        case let rawValue as TaskDetailResult.ActivateTaskResult :
            switch rawValue.rawValue {
            case let rawValue as TaskDetailResult.ActivateTaskResult.RawValue.Success:
                self = .ActivateTaskResult(.Success(.Success(task: rawValue.task)))
            case let rawValue as TaskDetailResult.ActivateTaskResult.RawValue.Failure:
                self = .ActivateTaskResult(.Failure(.Failure(error: rawValue.error)))
            case is TaskDetailResult.ActivateTaskResult.RawValue.InFlight:
                self = .ActivateTaskResult(.InFlight)
            case is TaskDetailResult.ActivateTaskResult.RawValue.HideUiNotification:
                self = .ActivateTaskResult(.HideUiNotification)
            default:
                self = .ActivateTaskResult(.InFlight)
            }
        case let rawValue as TaskDetailResult.CompleteTaskResult :
            switch rawValue.rawValue {
            case let rawValue as TaskDetailResult.CompleteTaskResult.RawValue.Success:
                self = .CompleteTaskResult(.Success(.Success(task: rawValue.task)))
            case let rawValue as TaskDetailResult.CompleteTaskResult.RawValue.Failure:
                self = .CompleteTaskResult(.Failure(.Failure(error: rawValue.error)))
            case is TaskDetailResult.CompleteTaskResult.RawValue.InFlight:
                self = .CompleteTaskResult(.InFlight)
            case is TaskDetailResult.CompleteTaskResult.RawValue.HideUiNotification:
                self = .CompleteTaskResult(.HideUiNotification)
            default:
                self = .CompleteTaskResult(.InFlight)
            }
        case let rawValue as TaskDetailResult.DeleteTaskResult :
            switch rawValue.rawValue {
            case is TaskDetailResult.DeleteTaskResult.RawValue.Success:
                self = .DeleteTaskResult(.Success(.Success()))
            case let rawValue as TaskDetailResult.DeleteTaskResult.RawValue.Failure:
                self = .DeleteTaskResult(.Failure(.Failure(error: rawValue.error)))
            case is TaskDetailResult.DeleteTaskResult.RawValue.InFlight:
                self = .DeleteTaskResult(.InFlight)
            default:
                self = .DeleteTaskResult(.InFlight)
            }
        default:
            self = .PopulateTaskResult(.InFlight)
        }
    }
    
    var rawValue: TaskDetailResult {
        switch self {
        case .PopulateTaskResult(let result) :
            switch result {
            case .Success(let result) :
                return TaskDetailResult(TaskDetailResult.PopulateTaskResult(rawValue: .Success(task: result.task))!)
            case .Failure(let result) :
                return TaskDetailResult(TaskDetailResult.PopulateTaskResult(rawValue: .Failure(error: result.error))!)
            case .InFlight :
                return TaskDetailResult(TaskDetailResult.PopulateTaskResult(rawValue: .InFlight())!)
            }
        case .ActivateTaskResult(let result) :
            switch result {
            case .Success(let result) :
                return TaskDetailResult(TaskDetailResult.ActivateTaskResult.Success(.Success(task: result.task)))
            case .Failure(let result) :
                return TaskDetailResult(TaskDetailResult.ActivateTaskResult.Failure(.Failure(error: result.error)))
            case .InFlight :
                return TaskDetailResult(TaskDetailResult.ActivateTaskResult.InFlight)
            default:
                return TaskDetailResult(TaskDetailResult.ActivateTaskResult.InFlight)
            }
        case .CompleteTaskResult(let result) :
            switch result {
            case .Success(let result) :
                return TaskDetailResult(TaskDetailResult.CompleteTaskResult.Success(.Success(task: result.task)))
            case .Failure(let result) :
                return TaskDetailResult(TaskDetailResult.CompleteTaskResult.Failure(.Failure(error: result.error)))
            case .InFlight :
                return TaskDetailResult(TaskDetailResult.CompleteTaskResult.InFlight)
            default:
                return TaskDetailResult(TaskDetailResult.CompleteTaskResult.InFlight)
            }
        case .DeleteTaskResult(let result) :
            switch result {
            case .Success :
                return TaskDetailResult(TaskDetailResult.DeleteTaskResult.Success(.Success()))
            case .Failure(let result) :
                return TaskDetailResult(TaskDetailResult.DeleteTaskResult.Failure(.Failure(error: result.error)))
            case .InFlight :
                return TaskDetailResult(TaskDetailResult.DeleteTaskResult.InFlight)
            }
        }
    }
    
    case PopulateTaskResult(TaskDetailResult.PopulateTaskResult)
    case ActivateTaskResult(TaskDetailResult.ActivateTaskResult)
    case CompleteTaskResult(TaskDetailResult.CompleteTaskResult)
    case DeleteTaskResult(TaskDetailResult.DeleteTaskResult)
}

protocol ProtocolTaskDetailResult {}

class TaskDetailResult  {
    var result: ProtocolTaskDetailResult
    
    init(_ result: ProtocolTaskDetailResult) {
        self.result = result
    }
}

class RawPopulateTaskResult {}
class RawActivateTaskDetailResult {}
class RawCompleteTaskDetailResult {}
class RawDeleteTaskResult {}

extension TaskDetailResult {
    
    enum PopulateTaskResult : ProtocolTaskDetailResult, RawRepresentable {
        typealias RawValue = RawPopulateTaskResult
        
        init?(rawValue: RawPopulateTaskResult) {
            switch rawValue {
            case let rawValue as RawValue.Success :
                self = .Success(.Success(task: rawValue.task))
            case let rawValue as RawValue.Failure :
                self = .Failure(.Failure(error: rawValue.error))
            case is RawValue.InFlight :
                self = .InFlight
            default :
                self = .InFlight
            }
        }
        
        var rawValue: RawValue {
            switch self {
            case .Success(let result) :
                return RawValue.Success(task: result.task)
            case .Failure(let exception) :
                return RawValue.Failure(error: exception.error)
            case .InFlight :
                return RawValue.InFlight()
            }
        }
        
        case Success(RawValue.Success)
        case Failure(RawValue.Failure)
        case InFlight
    }
    
    enum ActivateTaskResult : ProtocolTaskDetailResult, RawRepresentable {
        
        typealias RawValue = RawActivateTaskDetailResult
        
        init?(rawValue: RawValue) {
            switch rawValue {
            case let rawValue as RawValue.Success :
                self = .Success(.Success(task: rawValue.task))
            case let rawValue as RawValue.Failure :
                self = .Failure(.Failure(error: rawValue.error))
            case is RawValue.InFlight :
                self = .InFlight
            case is RawValue.HideUiNotification :
                self = .HideUiNotification
            default :
                self = .InFlight
            }
        }
        
        var rawValue: RawValue {
            switch self {
            case .Success(let result) :
                return RawValue.Success(task: result.task)
            case .Failure(let exception) :
                return RawValue.Failure(error: exception.error)
            case .InFlight :
                return RawValue.InFlight()
            case .HideUiNotification :
                return RawValue.HideUiNotification()
            }
        }
        
        case Success(RawValue.Success)
        case Failure(RawValue.Failure)
        case InFlight
        case HideUiNotification
    }
    
    enum CompleteTaskResult : ProtocolTaskDetailResult, RawRepresentable {
        
        typealias RawValue = RawCompleteTaskDetailResult
        
        init?(rawValue: RawValue) {
            switch rawValue {
            case let rawValue as RawValue.Success :
                self = .Success(.Success(task: rawValue.task))
            case let rawValue as RawValue.Failure :
                self = .Failure(.Failure(error: rawValue.error))
            case is RawValue.InFlight :
                self = .InFlight
            case is RawValue.HideUiNotification :
                self = .HideUiNotification
            default :
                self = .InFlight
            }
        }
        
        var rawValue: RawCompleteTaskDetailResult {
            switch self {
            case .Success(let result) :
                return RawValue.Success(task: result.task)
            case .Failure(let exception) :
                return RawValue.Failure(error: exception.error)
            case .InFlight :
                return RawValue.InFlight()
            case .HideUiNotification :
                return RawValue.HideUiNotification()
            }
        }
        
        case Success(RawValue.Success)
        case Failure(RawValue.Failure)
        case InFlight
        case HideUiNotification
    }
    
    enum DeleteTaskResult : ProtocolTaskDetailResult, RawRepresentable {
        
        typealias RawValue = RawDeleteTaskResult
        
        init?(rawValue: RawValue) {
            switch rawValue {
            case is RawValue.Success :
                self = .Success(.Success())
            case let rawValue as RawValue.Failure :
                self = .Failure(.Failure(error: rawValue.error))
            case is RawValue.InFlight :
                self = .InFlight
            default :
                self = .InFlight
            }
        }
        
        var rawValue: RawValue {
            switch self {
            case .Success :
                return RawValue.Success()
            case .Failure(let exception) :
                return RawValue.Failure(error: exception.error)
            case .InFlight :
                return RawValue.InFlight()
            }
        }
        
        case Success(RawValue.Success)
        case Failure(RawValue.Failure)
        case InFlight

    }
}

extension RawPopulateTaskResult {
    
    class Success : RawPopulateTaskResult {
        let task: Task
        
        init(task: Task) {
            self.task = task
        }
    }
    
    class Failure : RawPopulateTaskResult {
        let error: Error
        
        init(error: Error) {
            self.error = error
        }
    }
    
    class InFlight : RawPopulateTaskResult {}
}

extension RawActivateTaskDetailResult {
    
    class Success : RawActivateTaskDetailResult {
        let task: Task
        
        init(task: Task) {
            self.task = task
        }
    }
    
    class Failure : RawActivateTaskDetailResult {
        let error: Error
        
        init(error: Error) {
            self.error = error
        }
    }
    
    class InFlight : RawActivateTaskDetailResult {}
    class HideUiNotification : RawActivateTaskDetailResult {}
}

extension RawCompleteTaskDetailResult {
    
    class Success : RawCompleteTaskDetailResult {
        let task: Task
        
        init(task: Task) {
            self.task = task
        }
    }
    
    class Failure : RawCompleteTaskDetailResult {
        let error: Error
        
        init(error: Error) {
            self.error = error
        }
    }
    
    class InFlight : RawCompleteTaskDetailResult {}
    class HideUiNotification : RawCompleteTaskDetailResult {}
}

extension RawDeleteTaskResult {
    
    class Success : RawDeleteTaskResult {
        
    }
    
    class Failure : RawDeleteTaskResult {
        let error: Error
        
        init(error: Error) {
            self.error = error
        }
    }
    
    class InFlight : RawDeleteTaskResult {}
}

