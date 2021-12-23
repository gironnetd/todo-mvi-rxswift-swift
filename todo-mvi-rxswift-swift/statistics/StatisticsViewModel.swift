//
//  StatisticsViewModel.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 03/12/2021.
//

import Foundation
import RxSwift

class StatisticsViewModel {
    
    /**
     * Proxy subject used to keep the stream alive even after the UI gets recycled.
     * This is basically used to keep ongoing events and the last cached State alive
     * while the UI disconnects and reconnects on config changes.
     */
    private let actionProcessorHolder: StatisticsActionProcessorHolder
    private let intentsSubject: PublishSubject<Intent> = PublishSubject<Intent>()
    private lazy var statesObservable: Observable<ViewState> =  { return self.compose() }()
    lazy var compositeDisposable: CompositeDisposable = CompositeDisposable()
    
    init() {
        actionProcessorHolder = StatisticsActionProcessorHolder()
    }
    
    /**
     * take only the first ever InitialIntent and all intents of other types
     * to avoid reloading data on config changes
     */
    private lazy var intentFilter: ObservableTransformer<Intent, Intent> = { intents in
        return Observable.merge(
            intents.filter { tasksIntent in tasksIntent.rawValue is StatisticsIntent.InitialIntent }.take(1),
            intents.filter { tasksIntent in !(tasksIntent.rawValue is StatisticsIntent.InitialIntent) }
        )
    }
    
    /**
     * Compose all components to create the stream logic
     */
    private func compose() -> Observable<StatisticsViewState> {
        return intentsSubject
            .compose(intentFilter)
            .map(actionFromIntent)
            .compose(actionProcessorHolder.actionProcessor)
            // Cache each state and pass it to the reducer to create a new state from
            // the previous cached one and the latest Result emitted from the action processor.
            // The Scan operator is used here for the caching.
            .scan(StatisticsViewState.idle(), accumulator: reducer)
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
    
    private lazy var reducer: (_ previousState: StatisticsViewState, _ statisticsResult: StatisticsResult) -> StatisticsViewState = { previousState, statisticsResult in
        switch statisticsResult.result {
        case let result as StatisticsResult.LoadStatisticsResult :
            switch result.rawValue {
            case let result as StatisticsResult.LoadStatisticsResult.RawValue.Success :
                return previousState.copy(
                    isLoading: false,
                    activeCount: result.activeCount,
                    completedCount: result.completedCount
                )
            case let exception as StatisticsResult.LoadStatisticsResult.RawValue.Failure:
                return previousState.copy(isLoading: false, error: exception.error)
            case is StatisticsResult.LoadStatisticsResult.RawValue.InFlight:
                return previousState.copy(isLoading: true)
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
    private func actionFromIntent(intent: Intent) -> StatisticsAction {
        switch(intent) {
        case .InitialIntent :
            return StatisticsAction.LoadStatisticsAction()
        }
    }
}

extension StatisticsViewModel : MviViewModel {
    
    typealias Intent = EnumStatisticsIntent
    typealias ViewState = StatisticsViewState
    
    func processIntents(intents: Observable<Intent>) {
        _ = compositeDisposable.insert(intents.subscribe(intentsSubject))
    }
    
    func states() -> Observable<StatisticsViewState> {
        return statesObservable
    }
}
