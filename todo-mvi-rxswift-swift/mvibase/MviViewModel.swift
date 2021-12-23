//
//  MviViewModel.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 01/12/2021.
//

import RxSwift

protocol MviViewModel {
    
    associatedtype Intent: MviIntent
    associatedtype ViewState: MviViewState
    
    func processIntents(intents: Observable<Intent>)
    func states() -> Observable<ViewState>
}
