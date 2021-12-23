//
//  ObservableUtils.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 15/12/2021.
//

import Foundation
import RxSwift

/**
 * Emit an event immediately, then emit an other event after a delay has passed.
 * It is used for time limited UI state (e.g. a snackbar) to allow the stream to control
 * the timing for the showing and the hiding of a UI component.
 *
 * @param immediate Immediately emitted event
 * @param delayed   Event emitted after a delay
 */
func  pairWithDelay<T>(_ immediate: T,_ delayed: T) -> Observable<T> {
    return Observable<Int>.timer(RxTimeInterval.seconds(2), scheduler:  SerialDispatchQueueScheduler(qos: .background))
        .map { _ in delayed }
        .startWith(immediate)
      
}
