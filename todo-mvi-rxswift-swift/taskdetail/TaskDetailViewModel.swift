//
//  TaskDetailViewModel.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 03/12/2021.
//

import Foundation
import RxSwift

class TaskDetailViewModel {
    
    /**
     * Proxy subject used to keep the stream alive even after the UI gets recycled.
     * This is basically used to keep ongoing events and the last cached State alive
     * while the UI disconnects and reconnects on config changes.
     */
    private let actionProcessorHolder: TaskDetailActionProcessorHolder
    private let intentsSubject: PublishSubject<Intent> = PublishSubject<Intent>()
    private lazy var statesObservable: Observable<ViewState> =  { return self.compose() }()
    lazy var compositeDisposable: CompositeDisposable = CompositeDisposable()
    
    init() {
        actionProcessorHolder = TaskDetailActionProcessorHolder()
    }
    
    /**
     * take only the first ever InitialIntent and all intents of other types
     * to avoid reloading data on config changes
     */
    private lazy var intentFilter: ObservableTransformer<Intent, Intent> = { intents in
        return Observable.merge(
            intents.filter { tasksIntent in tasksIntent.rawValue is TaskDetailIntent.InitialIntent }.take(1),
            intents.filter { tasksIntent in !(tasksIntent.rawValue is TaskDetailIntent.InitialIntent) }
        )
    }
    
    /**
     * Compose all components to create the stream logic
     */
    private func compose() -> Observable<TaskDetailViewState> {
        return intentsSubject
            .compose(intentFilter)
            .map(actionFromIntent)
            .compose(actionProcessorHolder.actionProcessor)
            // Cache each state and pass it to the reducer to create a new state from
            // the previous cached one and the latest Result emitted from the action processor.
            // The Scan operator is used here for the caching.
            .scan(TaskDetailViewState.idle(), accumulator: reducer)
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
    
    private lazy var reducer: (_ previousState: TaskDetailViewState, _ taskDetailResult: TaskDetailResult) -> TaskDetailViewState = { previousState, taskDetailResult in
        switch taskDetailResult.result {
        case let result as TaskDetailResult.PopulateTaskResult :
            switch result.rawValue {
            case let result as TaskDetailResult.PopulateTaskResult.RawValue.Success :
                return previousState.copy(
                    title : result.task.title,
                    description : result.task.taskDescription,
                    active : result.task.active,
                    loading : false
                )
            case let exception as TaskDetailResult.PopulateTaskResult.RawValue.Failure:
                return previousState.copy(loading: false, error: exception.error)
            case is TaskDetailResult.PopulateTaskResult.RawValue.InFlight:
                return previousState.copy(loading: true)
            default:
                return previousState
            }
        case let result as TaskDetailResult.CompleteTaskResult :
            switch result.rawValue {
            case let result as TaskDetailResult.CompleteTaskResult.RawValue.Success :
                return previousState.copy(
                    active : false,
                    uiNotification : .TASK_COMPLETE
                )
            case let exception as TaskDetailResult.CompleteTaskResult.RawValue.Failure :
                return previousState.copy(error: exception.error)
            case is TaskDetailResult.CompleteTaskResult.RawValue.InFlight :
                return previousState
            case is TaskDetailResult.CompleteTaskResult.RawValue.HideUiNotification :
                if previousState.uiNotification == .TASK_COMPLETE {
                    return previousState.copy(uiNotification: nil)
                } else {
                    return previousState
                }
            default:
                return previousState
            }
        case let result as TaskDetailResult.ActivateTaskResult :
            switch result.rawValue {
            case let result as TaskDetailResult.ActivateTaskResult.RawValue.Success :
                return previousState.copy(
                    active : true,
                    uiNotification : .TASK_ACTIVATED
                )
            case let exception as TaskDetailResult.ActivateTaskResult.RawValue.Failure :
                return previousState.copy(error: exception.error)
            case is TaskDetailResult.ActivateTaskResult.RawValue.InFlight :
                return previousState
            case is TaskDetailResult.ActivateTaskResult.RawValue.HideUiNotification :
                if previousState.uiNotification == .TASK_ACTIVATED {
                    return previousState.copy(uiNotification: nil)
                } else {
                    return previousState
                }
            default:
                return previousState
            }
        case let result as TaskDetailResult.DeleteTaskResult :
            switch result.rawValue {
            case let result as TaskDetailResult.DeleteTaskResult.RawValue.Success :
                return previousState.copy(uiNotification : .TASK_DELETED)
            case let exception as TaskDetailResult.DeleteTaskResult.RawValue.Failure :
                return previousState.copy(error: exception.error)
            case is TaskDetailResult.DeleteTaskResult.RawValue.InFlight :
                return previousState
            default:
                return previousState
            }
        default:
            return previousState
        }
    }
    
    /**
     * Translate an [MviIntent] to an [MviAction].
     * Used to decouple the UI and the business logic to allow easy testings and reusability.
     */
    private func actionFromIntent(intent: Intent) -> TaskDetailAction {
        switch(intent) {
        case .InitialIntent (let intent):
            return TaskDetailAction.PopulateTaskAction(taskId: intent.taskId)
        case .DeleteTask (let intent) :
            return TaskDetailAction.DeleteTaskAction(taskId: intent.taskId)
        case .ActivateTaskIntent (let intent) :
            return TaskDetailAction.ActivateTaskAction(taskId: intent.taskId)
        case .CompleteTaskIntent (let intent) :
            return TaskDetailAction.CompleteTaskAction(taskId: intent.taskId)
        }
    }
}

extension TaskDetailViewModel : MviViewModel {
    
    typealias Intent = EnumTaskDetailIntent
    typealias ViewState = TaskDetailViewState
    
    func processIntents(intents: Observable<Intent>) {
        _ = compositeDisposable.insert(intents.subscribe(intentsSubject))
    }
    
    func states() -> Observable<TaskDetailViewState> {
        return statesObservable
    }
}
