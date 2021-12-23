//
//  StatisticsProcessorHolder.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 03/12/2021.
//

import Foundation
import RxSwift
import CoreData

class StatisticsActionProcessorHolder {
    
    private lazy var tasksRepository = TasksRepository.instance
    
    private lazy var loadStatisticsProcessor:
        ObservableTransformer<StatisticsAction.LoadStatisticsAction, StatisticsResult.LoadStatisticsResult> = { actions in
            return actions.flatMap { action in
                return self.tasksRepository.getTasks()
                    .asObservable()
                    .map { tasks in
                        StatisticsResult.LoadStatisticsResult.Success(.init(activeCount: tasks.filter { task in task.active}.count, completedCount: tasks.filter { task in !task.active}.count)
                        )
                    }
                    .catch { exception in
                        return Observable.just(StatisticsResult.LoadStatisticsResult.Failure(.init(error: exception)))
                    }
                    .subscribe(on: SerialDispatchQueueScheduler(qos: .background))
                    .observe(on: MainScheduler.asyncInstance)
                    .startWith(StatisticsResult.LoadStatisticsResult.InFlight)
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
    internal lazy var actionProcessor: ObservableTransformer<StatisticsAction, StatisticsResult> = { actions in
        return Observable.merge(
            // Match LoadStatisticsAction to loadStatisticsProcessor
            actions.filter { action in action is StatisticsAction.LoadStatisticsAction }
                .map { value in value as! StatisticsAction.LoadStatisticsAction }
                .compose(self.loadStatisticsProcessor)
                .flatMap { value in return Observable.just(StatisticsResult(value)) }
        )
    }
}

