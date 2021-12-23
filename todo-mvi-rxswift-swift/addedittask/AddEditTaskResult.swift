//
//  AddEditTaskResult.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 03/12/2021.
//

import Foundation

enum EnumAddEditTaskResult: MviResult, RawRepresentable {
    
    typealias RawValue = AddEditTaskResult
    
    init?(rawValue: AddEditTaskResult) {
        switch rawValue.result {
        
        case let rawValue as AddEditTaskResult.PopulateTaskResult :
            switch rawValue.rawValue {
            case let rawValue as AddEditTaskResult.PopulateTaskResult.RawValue.Success:
                self = .PopulateTaskResult(.Success(.Success(task: rawValue.task))!)
            case let rawValue as AddEditTaskResult.PopulateTaskResult.RawValue.Failure:
                self = .PopulateTaskResult(.Failure(.Failure(error: rawValue.error)))
            case is AddEditTaskResult.PopulateTaskResult.RawValue.InFlight:
                self = .PopulateTaskResult(.InFlight)
            default:
                self = .PopulateTaskResult(.InFlight)
            }
        case let rawValue as AddEditTaskResult.CreateTaskResult :
            switch rawValue.rawValue {
            case is AddEditTaskResult.CreateTaskResult.RawValue.Success:
                self = .CreateTaskResult(.Success)
            case is AddEditTaskResult.CreateTaskResult.RawValue.Empty:
                self = .CreateTaskResult(.Empty)
            default:
                self = .CreateTaskResult(.Empty)
            }
        case is AddEditTaskResult.UpdateTaskResult :
            self = .UpdateTaskResult
        default:
            self = .PopulateTaskResult(.InFlight)
        }
    }
    
    var rawValue: AddEditTaskResult {
        switch self {
        case .PopulateTaskResult(let result) :
            switch result {
            case .Success(let result) :
                return AddEditTaskResult(AddEditTaskResult.PopulateTaskResult(rawValue: .Success(task: result.task))!)
            case .Failure(let result) :
                return AddEditTaskResult(AddEditTaskResult.PopulateTaskResult(rawValue: .Failure(error: result.error))!)
            case .InFlight :
                return AddEditTaskResult(AddEditTaskResult.PopulateTaskResult(rawValue: .InFlight())!)
            }
        case .CreateTaskResult(let result) :
            switch result {
            case .Success :
                return AddEditTaskResult(AddEditTaskResult.CreateTaskResult.Success)
            case .Empty :
                return AddEditTaskResult(AddEditTaskResult.CreateTaskResult.Empty)
            }
        case .UpdateTaskResult :
            return AddEditTaskResult(AddEditTaskResult.UpdateTaskResult())
        }
    }
    
    case PopulateTaskResult(AddEditTaskResult.PopulateTaskResult)
    case CreateTaskResult(AddEditTaskResult.CreateTaskResult)
    case UpdateTaskResult
}

protocol ProtocolAddEditTaskResult {}

class AddEditTaskResult  {
    var result: ProtocolAddEditTaskResult?
    
    init(_ result: ProtocolAddEditTaskResult? = nil) {
        self.result = result
    }
}

class RawPopulateAddEditTaskResult {}
class RawCreateAddEditTaskResult {}
class RawUpdateAddEditTaskResult {}

extension AddEditTaskResult {
    
    enum PopulateTaskResult : ProtocolAddEditTaskResult, RawRepresentable {
        typealias RawValue = RawPopulateAddEditTaskResult
        
        init?(rawValue: RawPopulateAddEditTaskResult) {
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
    
    enum CreateTaskResult : ProtocolAddEditTaskResult, RawRepresentable {
        
        typealias RawValue = RawCreateAddEditTaskResult
        
        init?(rawValue: RawValue) {
            switch rawValue {
            case is RawValue.Success :
                self = .Success
            case is RawValue.Empty :
                self = .Empty
            default :
                self = .Empty
            }
        }
        
        var rawValue: RawValue {
            switch self {
            case .Success :
                return RawValue.Success()
            case .Empty :
                return RawValue.Empty()
            }
        }
        
        case Success
        case Empty
    }
    
    class UpdateTaskResult: ProtocolAddEditTaskResult {}
}

extension RawPopulateAddEditTaskResult {
    
    class Success : RawPopulateAddEditTaskResult {
        let task: Task
        
        init(task: Task) {
            self.task = task
        }
    }
    
    class Failure : RawPopulateAddEditTaskResult {
        let error: Error
        
        init(error: Error) {
            self.error = error
        }
    }
    
    class InFlight : RawPopulateAddEditTaskResult {}
}

extension RawCreateAddEditTaskResult {
    
    class Success : RawCreateAddEditTaskResult {}
    class Empty : RawCreateAddEditTaskResult {}
}
