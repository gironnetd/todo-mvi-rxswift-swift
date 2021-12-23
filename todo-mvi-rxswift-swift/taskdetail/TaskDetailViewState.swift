//
//  TaskDetailViewState.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 03/12/2021.
//

import Foundation

struct TaskDetailViewState : MviViewState {
    
    let title: String
    let description: String
    let active: Bool
    let loading: Bool
    let error: Error?
    let uiNotification: UiNotification?
    
    enum UiNotification {
        case TASK_COMPLETE, TASK_ACTIVATED, TASK_DELETED
    }
    
    static func idle() -> TaskDetailViewState {
        return TaskDetailViewState(
            title : "",
            description : "",
            active : false,
            loading : false,
            error : nil,
            uiNotification : nil
        )
    }
}

extension TaskDetailViewState {
    
    func copy(
        title: String? = nil,
        description: String? = nil,
        active: Bool? = nil,
        loading: Bool? = nil,
        error: Error? = nil,
        uiNotification: UiNotification? = nil
        ) -> TaskDetailViewState {
        TaskDetailViewState(
            title: title ?? self.title,
            description: description ?? self.description,
            active: active ?? self.active,
            loading: loading ?? self.loading,
            error: error ?? self.error,
            uiNotification: uiNotification ?? .none
        )
    }
}

extension TaskDetailViewState : Equatable {
    static func == (lhs: TaskDetailViewState, rhs: TaskDetailViewState) -> Bool {
        return
            lhs.title == rhs.title &&
            lhs.description == rhs.description &&
            lhs.active == rhs.active &&
            lhs.loading == rhs.loading &&
            lhs.error?.localizedDescription == rhs.error?.localizedDescription &&
            lhs.uiNotification == rhs.uiNotification
    }
}

