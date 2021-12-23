//
//  TaskDetailProcessorHolder.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 03/12/2021.
//

import Foundation
import RxSwift
import CoreData

class TaskDetailActionProcessorHolder {
    
    private lazy var tasksRepository = TasksRepository.instance
    
    private lazy var populateTaskProcessor:
        ObservableTransformer<TaskDetailAction.PopulateTaskAction, TaskDetailResult.PopulateTaskResult> = { actions in
            return actions.flatMap { action in
                return self.tasksRepository.getTask(taskId: action.taskId)
                    .asObservable()
                    .map { task in
                        TaskDetailResult.PopulateTaskResult.Success(.init(task: task))
                    }
                    .catch { exception in
                        return Observable.just(TaskDetailResult.PopulateTaskResult.Failure(.init(error: exception)))
                    }
                    .subscribe(on: SerialDispatchQueueScheduler(qos: .background))
                    .observe(on: MainScheduler.asyncInstance)
                    .startWith(TaskDetailResult.PopulateTaskResult.InFlight)
            }
        }
    
    private lazy var activateTaskProcessor:
        ObservableTransformer<TaskDetailAction.ActivateTaskAction, TaskDetailResult.ActivateTaskResult> = { actions in
            return actions.flatMap { action in
                return self.tasksRepository.activateTask(taskId: action.taskId)
                    .andThen(self.tasksRepository.getTask(taskId: action.taskId))
                    .asObservable()
                    .flatMap { task in
                        return pairWithDelay(
                            TaskDetailResult.ActivateTaskResult.Success(.init(task: task)),
                            TaskDetailResult.ActivateTaskResult.HideUiNotification
                        )
                    }
                    .catch { exception in
                        return Observable.just(TaskDetailResult.ActivateTaskResult.Failure(.init(error: exception)))
                    }
                    .subscribe(on: SerialDispatchQueueScheduler(qos: .background))
                    .observe(on: MainScheduler.asyncInstance)
                    .startWith(TaskDetailResult.ActivateTaskResult.InFlight)
            }
        }
    
    private lazy var completeTaskProcessor:
        ObservableTransformer<TaskDetailAction.CompleteTaskAction, TaskDetailResult.CompleteTaskResult> = { actions in
            return actions.flatMap { action in
                return self.tasksRepository.completeTask(taskId: action.taskId)
                    .andThen(self.tasksRepository.getTask(taskId: action.taskId))
                    .asObservable()
                    .flatMap { task in
                        return pairWithDelay(
                            TaskDetailResult.CompleteTaskResult.Success(.init(task: task)),
                            TaskDetailResult.CompleteTaskResult.HideUiNotification
                        )
                    }
                    .catch { exception in
                        return Observable.just(TaskDetailResult.CompleteTaskResult.Failure(.init(error: exception)))
                    }
                    .subscribe(on: SerialDispatchQueueScheduler(qos: .background))
                    .observe(on: MainScheduler.asyncInstance)
                    .startWith(TaskDetailResult.CompleteTaskResult.InFlight)
            }
        }
    
    private lazy var deleteTaskProcessor:
        ObservableTransformer<TaskDetailAction.DeleteTaskAction, TaskDetailResult.DeleteTaskResult> = { actions in
            return actions.flatMap { action in
                return self.tasksRepository.deleteTask(taskId: action.taskId)
                    .andThen(self.tasksRepository.getTasks())
                    .asObservable()
                    .flatMap { tasks in
                        return Observable.just(TaskDetailResult.DeleteTaskResult.Success(.init()))

                    }
                    .catch { exception in
                        return Observable.just(TaskDetailResult.DeleteTaskResult.Failure(.init(error: exception)))
                    }
                    .subscribe(on: SerialDispatchQueueScheduler(qos: .background))
                    .observe(on: MainScheduler.asyncInstance)
                    .startWith(TaskDetailResult.DeleteTaskResult.InFlight)
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
    internal lazy var actionProcessor: ObservableTransformer<TaskDetailAction, TaskDetailResult> = { actions in
        return Observable.merge(
            // Match LoadTaskDetailAction to loadTaskDetailProcessor
            actions.filter { action in action is TaskDetailAction.PopulateTaskAction }
                .map { value in value as! TaskDetailAction.PopulateTaskAction }
                .compose(self.populateTaskProcessor)
                .flatMap { value in return Observable.just(TaskDetailResult(value)) },
            // Match ActivateTaskAction to populateTaskProcessor
            actions.filter { action in action is TaskDetailAction.ActivateTaskAction }
                .map { value in value as! TaskDetailAction.ActivateTaskAction }
                .compose(self.activateTaskProcessor)
                .flatMap { value in return Observable.just(TaskDetailResult(value)) },
            // Match CompleteTaskAction to completeTaskProcessor
            actions.filter { action in action is TaskDetailAction.CompleteTaskAction }
                .map { value in value as! TaskDetailAction.CompleteTaskAction }
                .compose(self.completeTaskProcessor)
                .flatMap { value in return Observable.just(TaskDetailResult(value)) },
            // Match CompleteTaskAction to completeTaskProcessor
            actions.filter { action in action is TaskDetailAction.DeleteTaskAction }
                .map { value in value as! TaskDetailAction.DeleteTaskAction }
                .compose(self.deleteTaskProcessor)
                .flatMap { value in return Observable.just(TaskDetailResult(value)) }
        )
    }
}
