//
//  TasksResult.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 03/12/2021.
//

import Foundation

enum EnumTasksResult: MviResult, RawRepresentable {
    
    typealias RawValue = TasksResult
    
    init?(rawValue: TasksResult) {
        switch rawValue.result {
        
        case let rawValue as TasksResult.LoadTasksResult :
            switch rawValue.rawValue {
            case let rawValue as TasksResult.LoadTasksResult.RawValue.Success:
                self = .LoadTasksResult(.Success(.Success(tasks: rawValue.tasks, filterType: rawValue.filterType))!)
            case let rawValue as TasksResult.LoadTasksResult.RawValue.Failure:
                self = .LoadTasksResult(.Failure(.Failure(error: rawValue.error)))
            case is TasksResult.LoadTasksResult.RawValue.InFlight:
                self = .LoadTasksResult(.InFlight)
            default:
                self = .LoadTasksResult(.InFlight)
            }
        case let rawValue as TasksResult.ActivateTaskResult :
            switch rawValue.rawValue {
            case let rawValue as TasksResult.ActivateTaskResult.RawValue.Success:
                self = .ActivateTaskResult(.Success(.Success(tasks: rawValue.tasks)))
            case let rawValue as TasksResult.ActivateTaskResult.RawValue.Failure:
                self = .ActivateTaskResult(.Failure(.Failure(error: rawValue.error)))
            case is TasksResult.ActivateTaskResult.RawValue.InFlight:
                self = .ActivateTaskResult(.InFlight)
            case is TasksResult.ActivateTaskResult.RawValue.HideUiNotification:
                self = .ActivateTaskResult(.HideUiNotification)
            default:
                self = .ActivateTaskResult(.InFlight)
            }
        case let rawValue as TasksResult.CompleteTaskResult :
            switch rawValue.rawValue {
            case let rawValue as TasksResult.CompleteTaskResult.RawValue.Success:
                self = .CompleteTaskResult(.Success(.Success(tasks: rawValue.tasks)))
            case let rawValue as TasksResult.CompleteTaskResult.RawValue.Failure:
                self = .CompleteTaskResult(.Failure(.Failure(error: rawValue.error)))
            case is TasksResult.CompleteTaskResult.RawValue.InFlight:
                self = .CompleteTaskResult(.InFlight)
            case is TasksResult.CompleteTaskResult.RawValue.HideUiNotification:
                self = .CompleteTaskResult(.HideUiNotification)
            default:
                self = .CompleteTaskResult(.InFlight)
            }
        case let rawValue as TasksResult.ClearCompletedTasksResult :
            switch rawValue.rawValue {
            case let rawValue as TasksResult.ClearCompletedTasksResult.RawValue.Success:
                self = .ClearCompletedTasksResult(.Success(.Success(tasks: rawValue.tasks)))
            case let rawValue as TasksResult.ClearCompletedTasksResult.RawValue.Failure:
                self = .ClearCompletedTasksResult(.Failure(.Failure(error: rawValue.error)))
            case is TasksResult.ClearCompletedTasksResult.RawValue.InFlight:
                self = .ClearCompletedTasksResult(.InFlight)
            case is TasksResult.ClearCompletedTasksResult.RawValue.HideUiNotification:
                self = .ClearCompletedTasksResult(.HideUiNotification)
            default:
                self = .ClearCompletedTasksResult(.InFlight)
            }
        default:
            self = .LoadTasksResult(.InFlight)
        }
    }
    
    var rawValue: TasksResult {
        switch self {
        case .LoadTasksResult(let result) :
            switch result {
            case .Success(let result) :
                return TasksResult(TasksResult.LoadTasksResult(rawValue: .Success(tasks: result.tasks, filterType: result.filterType))!)
            case .Failure(let result) :
                return TasksResult(TasksResult.LoadTasksResult(rawValue: .Failure(error: result.error))!)
            case .InFlight :
                return TasksResult(TasksResult.LoadTasksResult(rawValue: .InFlight())!)
            }
        case .ActivateTaskResult(let result) :
            switch result {
            case .Success(let result) :
                return TasksResult(TasksResult.ActivateTaskResult.Success(.Success(tasks: result.tasks)))
            case .Failure(let result) :
                return TasksResult(TasksResult.ActivateTaskResult.Failure(.Failure(error: result.error)))
            case .InFlight :
                return TasksResult(TasksResult.ActivateTaskResult.InFlight)
            default:
                return TasksResult(TasksResult.ActivateTaskResult.InFlight)
            }
        case .CompleteTaskResult(let result) :
            switch result {
            case .Success(let result) :
                return TasksResult(TasksResult.CompleteTaskResult.Success(.Success(tasks: result.tasks)))
            case .Failure(let result) :
                return TasksResult(TasksResult.CompleteTaskResult.Failure(.Failure(error: result.error)))
            case .InFlight :
                return TasksResult(TasksResult.CompleteTaskResult.InFlight)
            default:
                return TasksResult(TasksResult.CompleteTaskResult.InFlight)
            }
        case .ClearCompletedTasksResult(let result) :
            switch result {
            case .Success(let result) :
                return TasksResult(TasksResult.ClearCompletedTasksResult.Success(.Success(tasks: result.tasks)))
            case .Failure(let result) :
                return TasksResult(TasksResult.ClearCompletedTasksResult.Failure(.Failure(error: result.error)))
            case .InFlight :
                return TasksResult(TasksResult.ClearCompletedTasksResult.InFlight)
            default:
                return TasksResult(TasksResult.ClearCompletedTasksResult.InFlight)
            }
        }
    }
    
    case LoadTasksResult(TasksResult.LoadTasksResult)
    case ActivateTaskResult(TasksResult.ActivateTaskResult)
    case CompleteTaskResult(TasksResult.CompleteTaskResult)
    case ClearCompletedTasksResult(TasksResult.ClearCompletedTasksResult)
}

protocol ProtocolTasksResult {}

class TasksResult  {
    var result: ProtocolTasksResult
    
    init(_ result: ProtocolTasksResult) {
        self.result = result
    }
}

class RawLoadTasksResult {}
class RawActivateTaskResult {}
class RawCompleteTaskResult {}
class RawClearCompletedTasksResult {}

extension TasksResult {
    
    enum LoadTasksResult : ProtocolTasksResult, RawRepresentable {
        typealias RawValue = RawLoadTasksResult
        
        init?(rawValue: RawLoadTasksResult) {
            switch rawValue {
            case let rawValue as RawValue.Success :
                self = .Success(.Success(tasks: rawValue.tasks, filterType: rawValue.filterType))
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
                return RawValue.Success(tasks: result.tasks, filterType: result.filterType)
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
    
    enum ActivateTaskResult : ProtocolTasksResult, RawRepresentable {
        
        typealias RawValue = RawActivateTaskResult
        
        init?(rawValue: RawValue) {
            switch rawValue {
            case let rawValue as RawValue.Success :
                self = .Success(.Success(tasks: rawValue.tasks))
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
                return RawValue.Success(tasks: result.tasks)
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
    
    enum CompleteTaskResult : ProtocolTasksResult, RawRepresentable {
        
        typealias RawValue = RawCompleteTaskResult
        
        init?(rawValue: RawValue) {
            switch rawValue {
            case let rawValue as RawValue.Success :
                self = .Success(.Success(tasks: rawValue.tasks))
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
        
        var rawValue: RawCompleteTaskResult {
            switch self {
            case .Success(let result) :
                return RawValue.Success(tasks: result.tasks)
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
    
    enum ClearCompletedTasksResult : ProtocolTasksResult, RawRepresentable {
        
        typealias RawValue = RawClearCompletedTasksResult
        
        init?(rawValue: RawValue) {
            switch rawValue {
            case let rawValue as RawValue.Success :
                self = .Success(.Success(tasks: rawValue.tasks))
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
                return RawValue.Success(tasks: result.tasks)
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
}

extension RawLoadTasksResult {
    
    class Success : RawLoadTasksResult {
        let tasks: [Task]
        let filterType: TasksFilterType?
        
        init(tasks: [Task], filterType: TasksFilterType?) {
            self.tasks = tasks
            self.filterType = filterType
        }
    }
    
    class Failure : RawLoadTasksResult {
        let error: Error
        
        init(error: Error) {
            self.error = error
        }
    }
    
    class InFlight : RawLoadTasksResult {}
}

extension RawActivateTaskResult {
    
    class Success : RawActivateTaskResult {
        let tasks: [Task]
        
        init(tasks: [Task]) {
            self.tasks = tasks
        }
    }
    
    class Failure : RawActivateTaskResult {
        let error: Error
        
        init(error: Error) {
            self.error = error
        }
    }
    
    class InFlight : RawActivateTaskResult {}
    class HideUiNotification : RawActivateTaskResult {}
}

extension RawCompleteTaskResult {
    
    class Success : RawCompleteTaskResult {
        let tasks: [Task]
        
        init(tasks: [Task]) {
            self.tasks = tasks
        }
    }
    
    class Failure : RawCompleteTaskResult {
        let error: Error
        
        init(error: Error) {
            self.error = error
        }
    }
    
    class InFlight : RawCompleteTaskResult {}
    class HideUiNotification : RawCompleteTaskResult {}
}

extension RawClearCompletedTasksResult {
    
    class Success : RawClearCompletedTasksResult {
        let tasks: [Task]
        
        init(tasks: [Task]) {
            self.tasks = tasks
        }
    }
    
    class Failure : RawClearCompletedTasksResult {
        let error: Error
        
        init(error: Error) {
            self.error = error
        }
    }
    
    class InFlight : RawClearCompletedTasksResult {}
    class HideUiNotification : RawClearCompletedTasksResult {}
}
