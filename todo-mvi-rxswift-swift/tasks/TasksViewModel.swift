//
//  TasksViewModel.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 03/12/2021.
//

import Foundation
import RxSwift

class TasksViewModel {
    
    /**
     * Proxy subject used to keep the stream alive even after the UI gets recycled.
     * This is basically used to keep ongoing events and the last cached State alive
     * while the UI disconnects and reconnects on config changes.
     */
    private let actionProcessorHolder: TasksActionProcessorHolder
    private let intentsSubject: PublishSubject<Intent> = PublishSubject<Intent>()
    private lazy var statesObservable: Observable<ViewState> =  { return self.compose() }()
    lazy var compositeDisposable: CompositeDisposable = CompositeDisposable()
    
    init() {
        actionProcessorHolder = TasksActionProcessorHolder()
    }
    
    /**
     * take only the first ever InitialIntent and all intents of other types
     * to avoid reloading data on config changes
     */
    private lazy var intentFilter: ObservableTransformer<Intent, Intent> = { intents in
        return Observable.merge(
            intents.filter { tasksIntent in tasksIntent.rawValue is TasksIntent.InitialIntent }.take(1),
            intents.filter { tasksIntent in !(tasksIntent.rawValue is TasksIntent.InitialIntent) }
        )
    }
    
    /**
     * Compose all components to create the stream logic
     */
    private func compose() -> Observable<TasksViewState> {
        return intentsSubject
            .compose(intentFilter)
            .map(actionFromIntent)
            .compose(actionProcessorHolder.actionProcessor)
            // Cache each state and pass it to the reducer to create a new state from
            // the previous cached one and the latest Result emitted from the action processor.
            // The Scan operator is used here for the caching.
            .scan(TasksViewState.idle(), accumulator: reducer)
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
    
    private lazy var reducer: (_ previousState: TasksViewState, _ tasksResult: TasksResult) -> TasksViewState = { previousState, tasksResult in
        switch tasksResult.result {
        case let result as TasksResult.LoadTasksResult :
            switch result.rawValue {
            case let result as TasksResult.LoadTasksResult.RawValue.Success :
                let filterType = result.filterType ?? previousState.tasksFilterType
                let tasks = self.filteredTasks(tasks: result.tasks, filterType: filterType)
                return previousState.copy(
                    isLoading: false,
                    tasksFilterType: filterType,
                    tasks: tasks
                )
            case let exception as TasksResult.LoadTasksResult.RawValue.Failure:
                return previousState.copy(isLoading: false, error: exception.error)
            case is TasksResult.LoadTasksResult.RawValue.InFlight:
                return previousState.copy(isLoading: true)
            default:
                return previousState
            }
        case let result as TasksResult.CompleteTaskResult :
            switch result.rawValue {
            case let result as TasksResult.CompleteTaskResult.RawValue.Success :
                return previousState.copy(
                    tasks: self.filteredTasks(tasks: result.tasks, filterType: previousState.tasksFilterType),
                    uiNotification: .TASK_COMPLETE
                )
            case let exception as TasksResult.CompleteTaskResult.RawValue.Failure :
                return previousState.copy(error: exception.error)
            case is TasksResult.CompleteTaskResult.RawValue.InFlight :
                return previousState
            case is TasksResult.CompleteTaskResult.RawValue.HideUiNotification :
                if previousState.uiNotification == .TASK_COMPLETE {
                    return previousState.copy(uiNotification: nil)
                } else {
                    return previousState
                }
            default:
                return previousState
            }
        case let result as TasksResult.ActivateTaskResult :
            switch result.rawValue {
            case let result as TasksResult.ActivateTaskResult.RawValue.Success :
                return previousState.copy(
                    tasks: self.filteredTasks(tasks: result.tasks, filterType: previousState.tasksFilterType),
                    uiNotification: .TASK_ACTIVATED
                )
            case let exception as TasksResult.ActivateTaskResult.RawValue.Failure :
                return previousState.copy(error: exception.error)
            case is TasksResult.ActivateTaskResult.RawValue.InFlight :
                return previousState
            case is TasksResult.ActivateTaskResult.RawValue.HideUiNotification :
                if previousState.uiNotification == .TASK_ACTIVATED {
                    return previousState.copy(uiNotification: nil)
                } else {
                    return previousState
                }
            default:
                return previousState
            }
        case let result as TasksResult.ClearCompletedTasksResult :
            switch result.rawValue {
            case let result as TasksResult.ClearCompletedTasksResult.RawValue.Success :
                return previousState.copy(
                    tasks: self.filteredTasks(tasks: result.tasks, filterType: previousState.tasksFilterType),
                    uiNotification: .COMPLETE_TASKS_CLEARED
                )
            case let exception as TasksResult.ClearCompletedTasksResult.RawValue.Failure :
                return previousState.copy(error: exception.error)
            case is TasksResult.ClearCompletedTasksResult.RawValue.InFlight :
                return previousState
            case is TasksResult.ClearCompletedTasksResult.RawValue.HideUiNotification :
                if previousState.uiNotification == .COMPLETE_TASKS_CLEARED {
                    return previousState.copy(uiNotification: nil)
                } else {
                    return previousState
                }
            default:
                return previousState
            }
        default:
            return previousState
        }
    }
    
    private func filteredTasks(
        tasks: [Task],
        filterType: TasksFilterType
    ) -> [Task] {
        switch (filterType) {
        case .ALL_TASKS : return tasks
        case .ACTIVE_TASKS : return tasks .filter { task in task.active }
        case .COMPLETED_TASKS : return tasks .filter { task in task.completed }
        }
    }
    
    /**
     * Translate an [MviIntent] to an [MviAction].
     * Used to decouple the UI and the business logic to allow easy testings and reusability.
     */
    private func actionFromIntent(intent: Intent) -> TasksAction {
        switch(intent) {
        case .InitialIntent :
            return TasksAction.LoadTasksAction(forceUpdate: false, filterType: .ALL_TASKS)
        case .RefreshIntent (let intent) :
            return TasksAction.LoadTasksAction(forceUpdate: intent.forceUpdate, filterType: nil)
        case .ActivateTaskIntent (let intent) :
            return TasksAction.ActivateTaskAction(task: intent.task)
        case .CompleteTaskIntent (let intent) :
            return TasksAction.CompleteTaskAction(task: intent.task)
        case .ClearCompletedTasksIntent :
            return TasksAction.ClearCompletedTasksAction()
        case .ChangeFilterIntent (let intent) :
            return TasksAction.LoadTasksAction(forceUpdate: false, filterType: intent.filterType)
        }
    }
}

extension TasksViewModel : MviViewModel {
    
    typealias Intent = EnumTasksIntent
    typealias ViewState = TasksViewState
    
    func processIntents(intents: Observable<Intent>) {
        _ = compositeDisposable.insert(intents.subscribe(intentsSubject))
    }
    
    func states() -> Observable<TasksViewState> {
        return statesObservable
    }
}
