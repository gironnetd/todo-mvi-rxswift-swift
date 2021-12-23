//
//  TaskRepository.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 03/12/2021.
//

import Foundation
import RxSwift

class TasksRepository: TasksDataSource {
    
    private static var singleton = TasksRepository()
    
    static var instance : TasksRepository {
        return singleton
    }
    
    private lazy var tasksRemoteDataSource: TasksDataSource = TasksRemoteDataSource()
    private lazy var tasksLocalDataSource: TasksDataSource = TasksLocalDataSource()
    
    /**
     * This variable has package local visibility so it can be accessed from tests.
     */
    var cachedTasks: [String : Task]?  = nil
    
    /**
     * Marks the cache as invalid, to force an update the next time data is requested. This variable
     * has package local visibility so it can be accessed from tests.
     */
    var cacheIsDirty = false
    
    private func getAndCacheLocalTasks() -> Single<[Task]> {
        return tasksLocalDataSource.getTasks()
            .flatMap { tasks in
                Observable.from(tasks)
                    .do(onNext: { [self] task in cachedTasks![task.id] = task} )
                    .toArray()
            }
    }
    
    private func getAndSaveRemoteTasks() -> Single<[Task]> {
        return tasksRemoteDataSource.getTasks()
            .flatMap { tasks in
                 Observable.from(tasks)
                    .do(onNext: { [self] task in
                        _ = tasksLocalDataSource.saveTask(task: task)
                        cachedTasks![task.id] = task
                      }
                    ).toArray()
            }
            .do(onSuccess: { _ in self.cacheIsDirty = false })
    }
    
    /**
     * Gets tasks from cache, local data source (SQLite) or remote data source, whichever is
     * available first.
     */
    func getTasks() -> Single<[Task]> {
        // Respond immediately with cache if available and not dirty
        if (cachedTasks != nil && !cacheIsDirty /*&& !cachedTasks!.isEmpty */) {
            return Observable.from(cachedTasks!.values).toArray()
        } else if (cachedTasks == nil) {
            cachedTasks = [String : Task]()
        }
        
        let remoteTasks = getAndSaveRemoteTasks()
        
        if (cacheIsDirty) {
            return remoteTasks
        } else {
            // Query the local storage if available. If not, query the network.
            let localTasks = getAndCacheLocalTasks()
            return Observable.merge(
                localTasks.asObservable(), remoteTasks.asObservable()
            )
            .map { tasks in tasks }
            .filter { tasks in !tasks.isEmpty }
            .first()
            .flatMap { tasks in
                if(tasks != nil) {
                    return Single.just(tasks!)
                } else {
                    return Single.error(NSError(domain: "Tasks are Nil", code: -1, userInfo: nil))
                }
            }
        }
    }
    
    /**
     * Gets tasks from local data source (sqlite) unless the table is new or empty. In that case it
     * uses the network data source. This is done to simplify the sample.
     */
    func getTask(taskId: String) -> Single<Task> {
        let cachedTask = getTaskWithId(id: taskId)
        
        // Respond immediately with cache if available
        if (cachedTask != nil) {
            return Single.just(cachedTask!)
        }
        
        // LoadAction from server/persisted if needed.
        
        // Do in memory cache update to keep the app UI up to date
        if (cachedTasks == nil) {
            cachedTasks = [String : Task]()
        }
        
        // Is the task in the local data source? If not, query the network.
        let localTask = getTaskWithIdFromLocalRepository(taskId: taskId)
        let remoteTask = tasksRemoteDataSource.getTask(taskId: taskId)
            .do(onSuccess: { [self] task in
                _ = tasksLocalDataSource.saveTask(task: task)
                cachedTasks![task.id] = task
            })
        
        return Observable.merge(
            localTask.asObservable(), remoteTask.asObservable()
        )
        .map { task in task }
        .first()
        .flatMap { task in
            if(task != nil) {
                return Single.just(task!)
            } else {
                return Single.error(NSError(domain: "Task is Nil", code: -1, userInfo: nil))
            }
        }
    }
    
    func saveTask(task: Task) -> Completable {
        _ = tasksRemoteDataSource.saveTask(task: task)
        _ = tasksLocalDataSource.saveTask(task: task)
        
        // Do in memory cache update to keep the app UI up to date
        if (cachedTasks == nil) {
            cachedTasks = [String : Task]()
        }
        cachedTasks![task.id] = task
        
        return Completable.empty()
    }
    
    func completeTask(task: Task) -> Completable {
        _ = tasksRemoteDataSource.completeTask(task: task)
        _ = tasksLocalDataSource.completeTask(task: task)
        
        
        task.completed = true
        
        // Do in memory cache update to keep the app UI up to date
        if (cachedTasks == nil) {
            cachedTasks = [String : Task]()
        }
        
        cachedTasks![task.id] = task
        
        return Completable.empty()
    }
    
    func completeTask(taskId: String) -> Completable {
        let taskWithId = getTaskWithId(id: taskId)
        if (taskWithId != nil) {
            return  completeTask(task: taskWithId!)
        } else {
            return  Completable.empty()
        }
    }
    
    func activateTask(task: Task) -> Completable {
        _ = tasksRemoteDataSource.activateTask(task: task)
        _ = tasksLocalDataSource.activateTask(task: task)
        
        task.completed = false
        
        // Do in memory cache update to keep the app UI up to date
        if (cachedTasks == nil) {
            cachedTasks = [String : Task]()
        }
        cachedTasks![task.id] = task
        
        return Completable.empty()
    }
    
    func activateTask(taskId: String) -> Completable {
        let taskWithId = getTaskWithId(id: taskId)
        if (taskWithId != nil) {
            return  activateTask(task: taskWithId!)
        } else {
            return  Completable.empty()
        }
    }
    
    func clearCompletedTasks() -> Completable {
        _ = tasksRemoteDataSource.clearCompletedTasks()
        _ = tasksLocalDataSource.clearCompletedTasks()
        
        // Do in memory cache update to keep the app UI up to date
        if (cachedTasks == nil) {
            cachedTasks = [String : Task]()
        }
        
        for (id, task) in cachedTasks! {
            if(task.isFault) {
                cachedTasks!.removeValue(forKey: id)
            }
        }
        
        return Completable.empty()
    }
    
    func refreshTasks() {
        cacheIsDirty = true
    }
    
    func deleteAllTasks() {
        _ = tasksRemoteDataSource.deleteAllTasks()
        _ = tasksLocalDataSource.deleteAllTasks()
        
        if (cachedTasks == nil) {
            cachedTasks = [String : Task]()
        }
        cachedTasks!.removeAll()
    }
    
    func deleteTask(taskId: String) -> Completable {
        _ = tasksRemoteDataSource.deleteTask(taskId: taskId)
        _ = tasksLocalDataSource.deleteTask(taskId: taskId)
        
        cachedTasks!.removeValue(forKey: taskId)
        
        return Completable.empty()
    }
    
    private func getTaskWithId(id: String) -> Task? {
        return cachedTasks?[id]
    }
    
    private func getTaskWithIdFromLocalRepository(taskId: String) -> Single<Task> {
        return tasksLocalDataSource.getTask(taskId: taskId)
            .do(onSuccess: { [self] task in cachedTasks![task.id] = task })
    }
}
