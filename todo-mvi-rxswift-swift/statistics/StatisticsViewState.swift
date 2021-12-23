//
//  StatisticsViewState.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 03/12/2021.
//

import Foundation

struct StatisticsViewState : MviViewState {
    
    let isLoading: Bool
    let activeCount: Int
    let completedCount: Int
    let error: Error?
    
    static func idle() -> StatisticsViewState {
        return StatisticsViewState(
            isLoading: false,
            activeCount: 0,
            completedCount: 0,
            error: nil
        )
    }
}

extension StatisticsViewState {

    func copy(isLoading: Bool? = nil, activeCount: Int? = nil, completedCount: Int? = nil,
              error: Error? = nil) -> StatisticsViewState {
        StatisticsViewState(
            isLoading: isLoading ?? self.isLoading,
            activeCount: activeCount ?? self.activeCount,
            completedCount: completedCount ?? self.completedCount,
            error: error ?? self.error
        )
    }
}

extension StatisticsViewState : Equatable {
    static func == (lhs: StatisticsViewState, rhs: StatisticsViewState) -> Bool {
        return
            lhs.isLoading == rhs.isLoading &&
            lhs.activeCount == rhs.activeCount &&
            lhs.completedCount == rhs.completedCount &&
            lhs.error?.localizedDescription == rhs.error?.localizedDescription
    }
}
