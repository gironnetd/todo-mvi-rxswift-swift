//
//  RxExt.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 03/12/2021.
//

import Foundation
import RxSwift

extension ObservableType {
    func compose<T>(_ transform: (Observable<Self.Element>) -> Observable<T>) -> Observable<T> {
        return transform(self.asObservable())
    }
}

typealias ObservableTransformer<I, O> = (Observable<I>) -> Observable<O>

