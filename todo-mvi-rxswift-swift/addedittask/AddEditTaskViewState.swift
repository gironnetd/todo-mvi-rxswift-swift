//
//  AddEditTaskViewState.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 03/12/2021.
//

import Foundation

struct AddEditTaskViewState : MviViewState {
    
    let isEmpty: Bool
    let isSaved: Bool
    let title: String
    let description: String
    let error: Error?
    
    static func idle() -> AddEditTaskViewState {
        return AddEditTaskViewState(
            isEmpty : false,
            isSaved : false,
            title : "",
            description : "",
            error : nil
        )
    }
}

extension AddEditTaskViewState {
    
    func copy(
        isEmpty: Bool? = nil,
        isSaved: Bool? = nil,
        title: String? = nil,
        description: String? = nil,
        error: Error? = nil
    ) -> AddEditTaskViewState {
        AddEditTaskViewState(
            isEmpty : isEmpty ?? self.isEmpty,
            isSaved : isSaved ?? self.isSaved,
            title : title ?? self.title,
            description : description ?? self.description,
            error : error ?? self.error
        )
    }
}

extension AddEditTaskViewState : Equatable {
    static func == (lhs: AddEditTaskViewState, rhs: AddEditTaskViewState) -> Bool {
        return
            lhs.isEmpty == rhs.isEmpty &&
            lhs.isSaved == rhs.isSaved &&
            lhs.title == rhs.title &&
            lhs.description == rhs.description &&
            lhs.error?.localizedDescription == rhs.error?.localizedDescription
    }
}

