//
//  AddEditTaskProcessorHolder.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 03/12/2021.
//

import Foundation
import RxSwift
import CoreData

class AddEditTaskActionProcessorHolder {
    
    private lazy var tasksRepository = TasksRepository.instance
    
    private lazy var populateTaskProcessor:
        ObservableTransformer<AddEditTaskAction.PopulateTaskAction, AddEditTaskResult.PopulateTaskResult> = { actions in
            return actions.flatMap { action in
                return self.tasksRepository.getTask(taskId: action.taskId)
                    .asObservable()
                    .map { task in
                        AddEditTaskResult.PopulateTaskResult.Success(.init(task: task))
                    }
                    .catch { exception in
                        return Observable.just(AddEditTaskResult.PopulateTaskResult.Failure(.init(error: exception)))
                    }
                    .subscribe(on: SerialDispatchQueueScheduler(qos: .background))
                    .observe(on: MainScheduler.asyncInstance)
                    .startWith(AddEditTaskResult.PopulateTaskResult.InFlight)
            }
        }
    
    private lazy var createTaskProcessor:
        ObservableTransformer<AddEditTaskAction.CreateTaskAction, AddEditTaskResult.CreateTaskResult> = { actions in
            actions
                .map { action in Task(title : action.title, taskDescription: action.description ) }
                .flatMap { task in
                    return Observable.merge(
                        Observable.just(task).filter { task in task.empty }.map {_ in AddEditTaskResult.CreateTaskResult.Empty },
                        Observable.just(task).filter { task in task.empty }.flatMap {_ in
                            self.tasksRepository.saveTask(task: task).andThen(Observable.just(AddEditTaskResult.CreateTaskResult.Success))
                        }
                    )
                }
        }
    
    private lazy var updateTaskProcessor:
        ObservableTransformer<AddEditTaskAction.UpdateTaskAction, AddEditTaskResult.UpdateTaskResult> = { actions in
            return actions.flatMap { action in
                return self.tasksRepository.saveTask(task: Task(id : action.taskId, title : action.title, taskDescription : action.description))
                    .andThen(Observable.just(AddEditTaskResult.UpdateTaskResult()))
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
    internal lazy var actionProcessor: ObservableTransformer<AddEditTaskAction, AddEditTaskResult> = { actions in
        return Observable.merge(
            // Match LoadAddEditTaskAction to populateTaskProcessor
            actions.filter { action in action is AddEditTaskAction.PopulateTaskAction }
                .map { value in value as! AddEditTaskAction.PopulateTaskAction }
                .compose(self.populateTaskProcessor)
                .flatMap { value in return Observable.just(AddEditTaskResult(value)) },
            // Match CompleteTaskAction to createTaskProcessor
            actions.filter { action in action is AddEditTaskAction.CreateTaskAction }
                .map { value in value as! AddEditTaskAction.CreateTaskAction }
                .compose(self.createTaskProcessor)
                .flatMap { value in return Observable.just(AddEditTaskResult(value)) },
            // Match CompleteTaskAction to updateTaskProcessor
            actions.filter { action in action is AddEditTaskAction.UpdateTaskAction }
                .map { value in value as! AddEditTaskAction.UpdateTaskAction }
                .compose(self.updateTaskProcessor)
                .flatMap { value in return Observable.just(AddEditTaskResult(value)) }
        )
    }
}

