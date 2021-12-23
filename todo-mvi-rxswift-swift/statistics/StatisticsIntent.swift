//
//  StatisticsIntent.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 03/12/2021.
//

import Foundation

enum EnumStatisticsIntent: MviIntent, RawRepresentable {
    
    typealias RawValue = StatisticsIntent
    
    init?(rawValue: StatisticsIntent) {
        switch rawValue {
        case is StatisticsIntent.InitialIntent:
            self = .InitialIntent
        default:
            self = .InitialIntent
        }
    }
    
    var rawValue: StatisticsIntent {
        switch self {
        case .InitialIntent:
            return StatisticsIntent.InitialIntent()
        }
    }
        
    case InitialIntent
}

class StatisticsIntent {}

extension StatisticsIntent {
    
    class InitialIntent: StatisticsIntent {}
}
