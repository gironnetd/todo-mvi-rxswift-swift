//
//  TaskDataSource.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 03/12/2021.
//

import Foundation
import RxSwift

/**
 * Main entry point for accessing tasks data.
 *
 *
 */
protocol TasksDataSource {
    
    func getTasks() -> Single<[Task]>
    
    func getTask(taskId: String) -> Single<Task>
    
    func saveTask(task: Task) -> Completable
    
    func completeTask(task: Task) -> Completable
    
    func completeTask(taskId: String) -> Completable
    
    func activateTask(task: Task) -> Completable
    
    func activateTask(taskId: String) -> Completable
    
    func clearCompletedTasks() -> Completable
    
    func refreshTasks()
    
    func deleteAllTasks()
    
    func deleteTask(taskId: String) -> Completable
}

extension TasksDataSource {
    func getTasks(forceUpdate: Bool) -> Single<[Task]> {
        if (forceUpdate) {
            refreshTasks()
        }
        return getTasks()
    }
}
