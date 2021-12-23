//
//  AddEditTaskViewModel.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 03/12/2021.
//

import Foundation
import RxSwift

class AddEditTaskViewModel {
    
    /**
     * Proxy subject used to keep the stream alive even after the UI gets recycled.
     * This is basically used to keep ongoing events and the last cached State alive
     * while the UI disconnects and reconnects on config changes.
     */
    private let actionProcessorHolder: AddEditTaskActionProcessorHolder
    private let intentsSubject: PublishSubject<Intent> = PublishSubject<Intent>()
    private lazy var statesObservable: Observable<ViewState> =  { return self.compose() }()
    lazy var compositeDisposable: CompositeDisposable = CompositeDisposable()
    
    init() {
        actionProcessorHolder = AddEditTaskActionProcessorHolder()
    }
    
    /**
     * take only the first ever InitialIntent and all intents of other types
     * to avoid reloading data on config changes
     */
    private lazy var intentFilter: ObservableTransformer<Intent, Intent> = { intents in
        return Observable.merge(
            intents.filter { tasksIntent in tasksIntent.rawValue is AddEditTaskIntent.InitialIntent }.take(1),
            intents.filter { tasksIntent in !(tasksIntent.rawValue is AddEditTaskIntent.InitialIntent) }
        )
    }
    
    /**
     * Compose all components to create the stream logic
     */
    private func compose() -> Observable<AddEditTaskViewState> {
        return intentsSubject
            .compose(intentFilter)
            .map(actionFromIntent)
            .compose(actionProcessorHolder.actionProcessor)
            // Cache each state and pass it to the reducer to create a new state from
            // the previous cached one and the latest Result emitted from the action processor.
            // The Scan operator is used here for the caching.
            .scan(AddEditTaskViewState.idle(), accumulator: reducer)
            // When a reducer just emits previousState, there's no reason to call render. In fact,
            // redrawing the UI in cases like this can cause jank (e.g. messing up snackbar animations
            // by showing the same snackbar twice in rapid succession).
            .distinctUntilChanged()
            // Emit the last one event of the stream on subscription
            // Useful when a View rebinds to the ViewModel after rotation.
            // Create the stream on creation without waiting for anyone to subscribe
            // This allows the stream to stay alive even when the UI disconnects and
            // match the stream's lifecycle to the ViewModel's one.
            .share(replay: 1, scope: .forever)
    }
    
    private lazy var reducer: (_ previousState: AddEditTaskViewState, _ addEditTaskResult: AddEditTaskResult) -> AddEditTaskViewState = { previousState, addEditTaskResult in
        switch addEditTaskResult.result {
                case let result as AddEditTaskResult.PopulateTaskResult :
                    switch result.rawValue {
                    case let result as AddEditTaskResult.PopulateTaskResult.RawValue.Success :
                        if(result.task.active) {
                            return previousState.copy(
                                title: result.task.title,
                                description: result.task.taskDescription
                            )
                        } else {
                            return previousState
                        }
                    case let exception as AddEditTaskResult.PopulateTaskResult.RawValue.Failure:
                        return previousState.copy(error: exception.error)
                    case is AddEditTaskResult.PopulateTaskResult.RawValue.InFlight:
                        return previousState
                    default:
                        return previousState
                    }
        case let result as AddEditTaskResult.CreateTaskResult :
            switch result.rawValue {
            case is AddEditTaskResult.CreateTaskResult.RawValue.Success :
                return previousState.copy(
                    isEmpty: false,
                    isSaved: true
                )
            case is AddEditTaskResult.CreateTaskResult.RawValue.Empty:
                return previousState.copy(isEmpty: true)
            default:
                return previousState
            }
        case is AddEditTaskResult.UpdateTaskResult :
            return previousState.copy(isSaved: true)
        default:
            return previousState
        }
    }
    
    /**
     * Translate an [MviIntent] to an [MviAction].
     * Used to decouple the UI and the business logic to allow easy testings and reusability.
     */
    private func actionFromIntent(intent: Intent) -> AddEditTaskAction {
        switch(intent) {
        case .InitialIntent (let intent) :
            if(intent.taskId == nil) {
                return .SkipMe()
            } else {
                return AddEditTaskAction.PopulateTaskAction(taskId: intent.taskId!)
            }
        case .SaveTask (let intent):
            if (intent.taskId == nil) {
                return .CreateTaskAction(title: intent.title, description: intent.description)
            } else {
                return .UpdateTaskAction(taskId: intent.taskId!, title: intent.title, description: intent.description)
            }
        }
    }
}

extension AddEditTaskViewModel : MviViewModel {
    
    typealias Intent = EnumAddEditTaskIntent
    typealias ViewState = AddEditTaskViewState
    
    func processIntents(intents: Observable<Intent>) {
        _ = compositeDisposable.insert(intents.subscribe(intentsSubject))
    }
    
    func states() -> Observable<AddEditTaskViewState> {
        return statesObservable
    }
}
