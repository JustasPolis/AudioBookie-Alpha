//
//  ActivityIndicator.swift
//  AudioBookie
//
//  Created by Justin on 2021-01-25.
//

import RxCocoa
import RxSwift

public class ActivityIndicator: SharedSequenceConvertibleType {
    public typealias Element = Bool
    public typealias SharingStrategy = DriverSharingStrategy

    private let _lock = NSRecursiveLock()
    private let _behavior = BehaviorRelay<Bool>(value: false)
    private let _loading: SharedSequence<SharingStrategy, Bool>

    public init() {
        _loading = _behavior.asDriver()
            .distinctUntilChanged()
    }

    fileprivate func trackActivityOfObservable<O: ObservableConvertibleType>(_ source: O) -> Observable<O.Element> {
        source.asObservable()
            .do(onNext: { _ in
                self.sendStopLoading()
            }, onError: { _ in
                self.sendStopLoading()
            }, onCompleted: {
                self.sendStopLoading()
            }, onSubscribe: subscribed)
    }

    private func subscribed() {
        _lock.lock()
        _behavior.accept(true)
        _lock.unlock()
    }

    private func sendStopLoading() {
        _lock.lock()
        _behavior.accept(false)
        _lock.unlock()
    }

    public func asSharedSequence() -> SharedSequence<SharingStrategy, Element> {
        _loading
    }
}

extension ObservableConvertibleType {
    public func trackActivity(_ activityIndicator: ActivityIndicator) -> Observable<Element> {
        activityIndicator.trackActivityOfObservable(self)
    }
}

