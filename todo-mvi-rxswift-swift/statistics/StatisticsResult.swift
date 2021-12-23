//
//  StatisticsResult.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 03/12/2021.
//

import Foundation

enum EnumStatisticsResult: MviResult, RawRepresentable {
    
    typealias RawValue = StatisticsResult
    
    init?(rawValue: StatisticsResult) {
        switch rawValue.result {
        
        case let rawValue as StatisticsResult.LoadStatisticsResult :
            switch rawValue.rawValue {
            case let rawValue as StatisticsResult.LoadStatisticsResult.RawValue.Success:
                self = .LoadStatisticsResult(.Success(.Success(activeCount: rawValue.activeCount, completedCount: rawValue.completedCount))!)
            case let rawValue as StatisticsResult.LoadStatisticsResult.RawValue.Failure:
                self = .LoadStatisticsResult(.Failure(.Failure(error: rawValue.error)))
            case is StatisticsResult.LoadStatisticsResult.RawValue.InFlight:
                self = .LoadStatisticsResult(.InFlight)
            default:
                self = .LoadStatisticsResult(.InFlight)
            }
        default:
            self = .LoadStatisticsResult(.InFlight)
        }
    }
    
    var rawValue: StatisticsResult {
        switch self {
        case .LoadStatisticsResult(let result) :
            switch result {
            case .Success(let result) :
                return StatisticsResult(StatisticsResult.LoadStatisticsResult(rawValue: .Success(activeCount: result.activeCount, completedCount: result.completedCount))!)
            case .Failure(let result) :
                return StatisticsResult(StatisticsResult.LoadStatisticsResult(rawValue: .Failure(error: result.error))!)
            case .InFlight :
                return StatisticsResult(StatisticsResult.LoadStatisticsResult(rawValue: .InFlight())!)
            }
        }
    }
    
    case LoadStatisticsResult(StatisticsResult.LoadStatisticsResult)
}

protocol ProtocolStatisticsResult {}

class StatisticsResult  {
    var result: ProtocolStatisticsResult
    
    init(_ result: ProtocolStatisticsResult) {
        self.result = result
    }
}

class RawLoadStatisticsResult {}

extension StatisticsResult {
    
    enum LoadStatisticsResult : ProtocolStatisticsResult, RawRepresentable {
        typealias RawValue = RawLoadStatisticsResult
        
        init?(rawValue: RawLoadStatisticsResult) {
            switch rawValue {
            case let rawValue as RawValue.Success :
                self = .Success(.Success(activeCount: rawValue.activeCount, completedCount: rawValue.completedCount))
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
                return RawValue.Success(activeCount: result.activeCount, completedCount: result.completedCount)
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

extension RawLoadStatisticsResult {
    
    class Success : RawLoadStatisticsResult {
        
        let activeCount: Int
        let completedCount: Int
        
        init(activeCount: Int, completedCount: Int) {
            self.activeCount = activeCount
            self.completedCount = completedCount
        }
    }
    
    class Failure : RawLoadStatisticsResult {
        let error: Error
        
        init(error: Error) {
            self.error = error
        }
    }
    
    class InFlight : RawLoadStatisticsResult {}
}
