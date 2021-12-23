//
//  TasksActionProcessorHolder.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 03/12/2021.
//

import Foundation
import RxSwift
import CoreData

class TasksActionProcessorHolder {
    
    private lazy var tasksRepository = TasksRepository.instance
    
    private lazy var loadTasksProcessor:
        ObservableTransformer<TasksAction.LoadTasksAction, TasksResult.LoadTasksResult> = { actions in
            return actions.flatMap { action in
                return self.tasksRepository.getTasks(forceUpdate: action.forceUpdate)
                    .asObservable()
                    .map { tasks in
                        TasksResult.LoadTasksResult.Success(.init(tasks: tasks, filterType: action.filterType))
                    }
                    .catch { exception in
                        return Observable.just(TasksResult.LoadTasksResult.Failure(.init(error: exception)))
                    }
                    .subscribe(on: SerialDispatchQueueScheduler(qos: .background))
                    .observe(on: MainScheduler.asyncInstance)
                    .startWith(TasksResult.LoadTasksResult.InFlight)
            }
        }
    
    private lazy var activateTaskProcessor:
        ObservableTransformer<TasksAction.ActivateTaskAction, TasksResult.ActivateTaskResult> = { actions in
            return actions.flatMap { action in
                return self.tasksRepository.activateTask(task: action.task)
                    .andThen(self.tasksRepository.getTasks())
                    .asObservable()
                    .flatMap { tasks in
                        return pairWithDelay(
                            TasksResult.ActivateTaskResult.Success(.init(tasks: tasks)),
                            TasksResult.ActivateTaskResult.HideUiNotification
                        )
                    }
                    .catch { exception in
                        return Observable.just(TasksResult.ActivateTaskResult.Failure(.init(error: exception)))
                    }
                    .subscribe(on: SerialDispatchQueueScheduler(qos: .background))
                    .observe(on: MainScheduler.asyncInstance)
                    .startWith(TasksResult.ActivateTaskResult.InFlight)
            }
        }
    
    private lazy var completeTaskProcessor:
        ObservableTransformer<TasksAction.CompleteTaskAction, TasksResult.CompleteTaskResult> = { actions in
            return actions.flatMap { action in
                return self.tasksRepository.completeTask(task: action.task)
                    .andThen(self.tasksRepository.getTasks())
                    .asObservable()
                    .flatMap { tasks in
                        return pairWithDelay(
                            TasksResult.CompleteTaskResult.Success(.init(tasks: tasks)),
                            TasksResult.CompleteTaskResult.HideUiNotification
                        )
                    }
                    .catch { exception in
                        return Observable.just(TasksResult.CompleteTaskResult.Failure(.init(error: exception)))
                    }
                    .subscribe(on: SerialDispatchQueueScheduler(qos: .background))
                    .observe(on: MainScheduler.asyncInstance)
                    .startWith(TasksResult.CompleteTaskResult.InFlight)
            }
        }
    
    private lazy var clearCompletedTasksProcessor:
        ObservableTransformer<TasksAction.ClearCompletedTasksAction, TasksResult.ClearCompletedTasksResult> = { actions in
            return actions.flatMap {_ in
                return self.tasksRepository.clearCompletedTasks()
                    .andThen(self.tasksRepository.getTasks())
                    .asObservable()
                    .flatMap { tasks in
                        return pairWithDelay(
                            TasksResult.ClearCompletedTasksResult.Success(.init(tasks: tasks)),
                            TasksResult.ClearCompletedTasksResult.HideUiNotification
                        )
                    }
                    .catch { exception in
                        return Observable.just(TasksResult.ClearCompletedTasksResult.Failure(.init(error: exception)))
                    }
                    .subscribe(on: SerialDispatchQueueScheduler(qos: .background))
                    .observe(on: MainScheduler.asyncInstance)
                    .startWith(TasksResult.ClearCompletedTasksResult.InFlight)
            }
        }
    
    /**
     * Splits the [Observable] to match each type of [MviAction] to
     * its corresponding business logic processor. Each processor takes a defined [MviAction],
     * returns a defined [MviResult]
     * The global actionProcessor then merges all [Observable] back to
     * one unique [Observable].
     *
     *
     * The splitting is done using [Observable.publish] which allows almost anything
     * on the passed [Observable] as long as one and only one [Observable] is returned.
     *
     *
     * An security layer is also added for unhandled [MviAction] to allow early crash
     * at runtime to easy the maintenance.
     */
    internal lazy var actionProcessor: ObservableTransformer<TasksAction, TasksResult> = { actions in
        return Observable.merge(
            // Match LoadTasksAction to loadTasksProcessor
            actions.filter { action in action is TasksAction.LoadTasksAction }
                .map { value in value as! TasksAction.LoadTasksAction }
                .compose(self.loadTasksProcessor)
                .flatMap { value in return Observable.just(TasksResult(value)) },
            // Match ActivateTaskAction to populateTaskProcessor
            actions.filter { action in action is TasksAction.ActivateTaskAction }
                .map { value in value as! TasksAction.ActivateTaskAction }
                .compose(self.activateTaskProcessor)
                .flatMap { value in return Observable.just(TasksResult(value)) },
            // Match CompleteTaskAction to completeTaskProcessor
            actions.filter { action in action is TasksAction.CompleteTaskAction }
                .map { value in value as! TasksAction.CompleteTaskAction }
                .compose(self.completeTaskProcessor)
                .flatMap { value in return Observable.just(TasksResult(value)) },
            // Match ClearCompletedTasksAction to clearCompletedTasksProcessor
            actions.filter { action in action is TasksAction.ClearCompletedTasksAction }
                .map { value in value as! TasksAction.ClearCompletedTasksAction }
                .compose(self.clearCompletedTasksProcessor)
                .flatMap { value in return Observable.just(TasksResult(value)) }
        )
    }
}
