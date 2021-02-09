//
//  ObservableType+Rx.swift
//  AudioBookie
//
//  Created by Justin on 2021-01-25.
//

import RxCocoa
import RxSwift

extension SharedSequenceConvertibleType where SharingStrategy == DriverSharingStrategy {

    func mapToVoid() -> SharedSequence<SharingStrategy, Void> {
        map { _ in }
    }

    public func mapTo<Result>(_ value: Result) -> SharedSequence<SharingStrategy, Result> {
        map { _ in value }
    }

    public func merge(with other: Driver<Element>) -> SharedSequence<SharingStrategy, Element> {
        Driver.merge(self as! SharedSequence<DriverSharingStrategy, Self.Element>, other)
    }

    func skip(if trigger: Driver<Bool>) -> SharedSequence<SharingStrategy, Element> {
        withLatestFrom(trigger) { (myValue, triggerValue) -> (Element, Bool) in
            (myValue, triggerValue)
        }
        .filter { (_, triggerValue) -> Bool in
            triggerValue == false
        }
        .map { (myValue, _) -> Element in
            myValue
        }
    }

    func take(if trigger: Driver<Bool>) -> SharedSequence<SharingStrategy, Element> {
        withLatestFrom(trigger) { (myValue, triggerValue) -> (Element, Bool) in
            (myValue, triggerValue)
        }
        .filter { (_, triggerValue) -> Bool in
            triggerValue == true
        }
        .map { (myValue, _) -> Element in
            myValue
        }
    }
}

extension ObservableType {

    func ignoreAll() -> Observable<Void> {
        map { _ in }
    }

    func asDriverOnErrorJustComplete() -> Driver<Element> {
        asDriver { _ in
            Driver.empty()
        }
    }

    func mapToVoid() -> Observable<Void> {
        map { _ in }
    }
}

extension PrimitiveSequence where Trait == SingleTrait, Element: Sequence {

    func asDriverOnErrorJustComplete() -> Driver<Element> {
        asDriver { _ in
            Driver.empty()
        }
    }
}
