//
//  TasksRemoteDataSource.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 12/12/2021.
//

import Foundation
import RxSwift

class TasksRemoteDataSource: TasksDataSource {
    
    lazy var tasksServiceData : [String : Task] = [String : Task]()
    
    func getTasks() -> Single<[Task]> {
        return Observable.from(tasksServiceData.values).toArray()
    }
    
    func getTask(taskId: String) -> Single<Task> {
        return Single.just(tasksServiceData[taskId]!)
    }
    
    func saveTask(task: Task) -> Completable {
        tasksServiceData[task.id] = task
        return Completable.empty()
    }
    
    func completeTask(task: Task) -> Completable {
        tasksServiceData[task.id]?.completed = true
        return Completable.empty()
    }
    
    func completeTask(taskId: String) -> Completable {
        // Not required for the remote data source because the {@link TasksRepository} handles
        // converting from a {@code taskId} to a {@link task} using its cached data.
        return Completable.empty()
    }
    
    func activateTask(task: Task) -> Completable {
        tasksServiceData[task.id]?.completed = false
        return Completable.empty()
    }
    
    func activateTask(taskId: String) -> Completable {
        // Not required for the remote data source because the {@link TasksRepository} handles
        // converting from a {@code taskId} to a {@link task} using its cached data.
        return Completable.empty()
    }
    
    func clearCompletedTasks() -> Completable {
        for (id, task) in tasksServiceData {
            if(task.completed) {
                tasksServiceData.removeValue(forKey: id)
            }
        }
        return Completable.empty()
    }
    
    func refreshTasks() {
        // Not required because the {@link TasksRepository} handles the logic of refreshing the
        // tasks from all the available data sources.
    }
    
    func deleteAllTasks() {
        tasksServiceData.removeAll()
    }
    
    func deleteTask(taskId: String) -> Completable {
        tasksServiceData.removeValue(forKey: taskId)
        return Completable.empty()
    }
}
