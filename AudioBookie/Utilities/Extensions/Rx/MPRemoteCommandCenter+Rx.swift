//
//  MPRemoteCommandCenter+Rx.swift
//  AudioBookie
//
//  Created by Justin on 2021-02-01.
//

import MediaPlayer
import RxCocoa
import RxSwift

extension Reactive where Base: MPRemoteCommandCenter {

    var playPauseCommand: Observable<Void> {
        Observable.create { [weak base = self.base] observer in
            guard let base = base else {
                observer.onCompleted()
                return Disposables.create()
            }
            base.togglePlayPauseCommand.addTarget { _ -> MPRemoteCommandHandlerStatus in
                observer.onNext(())
                return .success
            }
            return Disposables.create()
        }
    }

    var skipBackwardCommand: Observable<Void> {
        Observable.create { [weak base = self.base] observer in
            guard let base = base else {
                observer.onCompleted()
                return Disposables.create()
            }
            base.skipBackwardCommand.addTarget { _ -> MPRemoteCommandHandlerStatus in
                observer.onNext(())
                return .success
            }
            return Disposables.create()
        }
    }

    var skipForwardCommand: Observable<Void> {
        Observable.create { [weak base = self.base] observer in
            guard let base = base else {
                observer.onCompleted()
                return Disposables.create()
            }
            base.skipForwardCommand.addTarget { _ -> MPRemoteCommandHandlerStatus in
                observer.onNext(())
                return .success
            }
            return Disposables.create()
        }
    }

    var changePlaybackPositionCommand: Observable<Double> {
        Observable.create { [weak base = self.base] observer in
            guard let base = base else {
                observer.onCompleted()
                return Disposables.create()
            }

            base.changePlaybackPositionCommand.addTarget { event -> MPRemoteCommandHandlerStatus in
                guard let event = event as? MPChangePlaybackPositionCommandEvent else {
                    observer.onCompleted()
                    return .commandFailed
                }
                observer.onNext(event.positionTime)
                return .success
            }
            return Disposables.create()
        }
    }
}
