//
//  StatisticsAction.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 03/12/2021.
//

import Foundation

enum EnumStatisticsAction: MviAction, RawRepresentable {
    
    typealias RawValue = StatisticsAction
    
    init?(rawValue: StatisticsAction) {
        switch rawValue {
        case is StatisticsAction.LoadStatisticsAction:
            self = .LoadStatisticsAction
        default:
            self = .LoadStatisticsAction
        }
    }
    
    var rawValue: StatisticsAction {
        switch self {
        case .LoadStatisticsAction :
            return StatisticsAction.LoadStatisticsAction()
        }
    }
    
    case LoadStatisticsAction
}

class StatisticsAction: MviAction {}

extension StatisticsAction {

    class LoadStatisticsAction: StatisticsAction {}
}
