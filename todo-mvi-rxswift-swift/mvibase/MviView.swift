//
//  MviView.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 01/12/2021.
//
import UIKit
import Foundation
import RxSwift

protocol MviView {
    
    associatedtype Intent: MviIntent
    associatedtype ViewState: MviViewState
    
    func intents() -> Observable<Intent>
    
    func render(state: ViewState)
}
