//
//  TasksLocalDataSource.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 12/12/2021.
//

import Foundation
import RxSwift
import CoreData

class TasksLocalDataSource : TasksDataSource {
        
    func getTasks() -> Single<[Task]> {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try Task.managedContext.fetch(request)
            return Observable.from((result as! [Task])).toArray()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return Single.error(error)
        }
    }
    
    func getTask(taskId: String) -> Single<Task> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        request.predicate = NSPredicate(format: "identifiant = %@", taskId)
        request.returnsObjectsAsFaults = false

        do {
            let result = try Task.managedContext.fetch(request)
            let task = result.first as! Task
            return Single.just(task)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return Single.error(error)
        }
    }
    
    func saveTask(task: Task) -> Completable {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try Task.managedContext.fetch(request)
            var isAlreadySaved : Bool = false
            for localTask in (result as! [Task]) {
                if(localTask.id == task.id) {
                    isAlreadySaved = true
                    localTask.setValue(task.title, forKey: "title")
                    localTask.setValue(task.taskDescription, forKey: "taskDescription")
                    localTask.setValue(task.completed, forKey: "isCompleted")
                }
            }
            if(!isAlreadySaved) { Task.managedContext.insert(task) }
            try Task.managedContext.save()
            return Completable.empty()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return Completable.error(error)
        }
    }
    
    func completeTask(task: Task) -> Completable {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        request.predicate = NSPredicate(format: "identifiant = %@", task.id)
        request.returnsObjectsAsFaults = false

        do {
            let result = try Task.managedContext.fetch(request)
            let task = result.first as! Task
            task.completed = true
            try Task.managedContext.save()
            return Completable.empty()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return Completable.error(error)
        }
    }
    
    func completeTask(taskId: String) -> Completable {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        request.predicate = NSPredicate(format: "identifiant = %@", taskId)
        request.returnsObjectsAsFaults = false

        do {
            let result = try Task.managedContext.fetch(request)
            let task = result.first as! Task
            task.completed = true
            try Task.managedContext.save()
            return Completable.empty()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return Completable.error(error)
        }
    }
    
    func activateTask(task: Task) -> Completable {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        request.predicate = NSPredicate(format: "identifiant = %@", task.id)
        request.returnsObjectsAsFaults = false

        do {
            let result = try Task.managedContext.fetch(request)
            let task = result.first as! Task
            task.completed = false
            try Task.managedContext.save()
            return Completable.empty()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return Completable.error(error)
        }
    }
    
    func activateTask(taskId: String) -> Completable {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        request.predicate = NSPredicate(format: "identifiant = %@", taskId)
        request.returnsObjectsAsFaults = false

        do {
            let result = try Task.managedContext.fetch(request)
            let task = result.first as! Task
            task.completed = false
            try Task.managedContext.save()
            return Completable.empty()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return Completable.error(error)
        }
    }
    
    func clearCompletedTasks() -> Completable {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try Task.managedContext.fetch(request)
            for task in (result as! [Task]) {
                if(task.completed) {
                    Task.managedContext.delete(task)
                }
            }
            try Task.managedContext.save()
            return Completable.empty()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return Completable.error(error)
        }
    }
    
    func refreshTasks() {
        
    }
    
    func deleteAllTasks() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try Task.managedContext.fetch(request)
            for task in (result as! [Task]) {
                Task.managedContext.delete(task)
            }
            try Task.managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func deleteTask(taskId: String) -> Completable {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        request.predicate = NSPredicate(format: "identifiant = %@", taskId)
        request.returnsObjectsAsFaults = false

        do {
            let result = try Task.managedContext.fetch(request)
            let task = result.first as! Task
            Task.managedContext.delete(task)
            try Task.managedContext.save()
            return Completable.empty()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return Completable.error(error)
        }
    }
}
