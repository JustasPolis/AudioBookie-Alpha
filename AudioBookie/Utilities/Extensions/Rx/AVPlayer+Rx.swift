//
//  AVPlayer+Rx.swift
//  AudioBookie
//
//  Created by Justin on 2021-01-28.
//

import AVKit
import RxCocoa
import RxSwift

extension Reactive where Base: AVPlayer {

    var itemDidPlayToEndTime: ControlEvent<Void> {
        let source = NotificationCenter.default.rx.notification(NSNotification.Name.AVPlayerItemDidPlayToEndTime)
            .mapToVoid()
        return ControlEvent(events: source)
    }

    var timeControlStatus: Driver<AVPlayer.TimeControlStatus> {
        base.rx.observe(AVPlayer.TimeControlStatus.self, #keyPath(AVPlayer.timeControlStatus), options: [.initial, .new], retainSelf: false)
            .compactMap { $0 }
            .asDriverOnErrorJustComplete()
    }

    var currentItem: Driver<AVPlayerItem> {
        base.rx.observe(AVPlayerItem.self, #keyPath(AVPlayer.currentItem), options: [.initial, .new], retainSelf: true)
            .compactMap { $0 }
            .asDriverOnErrorJustComplete()
    }

    var status: Driver<AVPlayer.Status> {
        base.rx.observe(AVPlayer.Status.self, #keyPath(AVPlayer.status), options: [.initial, .new], retainSelf: false)
            .compactMap { $0 }
            .asDriverOnErrorJustComplete()
    }

    var readyToPlay: Driver<Bool> {
        base.rx.observe(AVPlayer.Status.self, #keyPath(AVPlayer.status), options: [.initial, .new], retainSelf: false)
            .compactMap { $0 }
            .map { $0 == .readyToPlay }
            .asDriverOnErrorJustComplete()
    }

    var handlePlayPause: Binder<AVPlayer.TimeControlStatus> {
        Binder(base) { player, status in
            switch status {
                case .playing:
                    player.pause()
                case .paused:
                    player.play()
                case .waitingToPlayAtSpecifiedRate:
                    player.pause()
                @unknown default:
                    break
            }
        }
    }

    var replaceItem: Binder<URL> {
        Binder(base) { player, url in
            let playerItem = AVPlayerItem(url: url)
            player.replaceCurrentItem(with: playerItem)
            player.play()
        }
    }

    func playbackPosition(updateInterval: TimeInterval, updateQueue: DispatchQueue?) -> Driver<TimeInterval> {
        Observable.create { [weak base] observer in

            guard let player = base else {
                observer.onCompleted()
                return Disposables.create()
            }

            let intervalTime = CMTime(seconds: updateInterval, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            let obj = player.addPeriodicTimeObserver(
                forInterval: intervalTime,
                queue: updateQueue,
                using: { positionTime in

                    observer.onNext(positionTime.seconds)
                })

            return Disposables.create {
                player.removeTimeObserver(obj)
            }
        }.asDriverOnErrorJustComplete()
    }
}

extension Reactive where Base: AVPlayerItem {
    var loading: Driver<Bool> {
        base.rx.observeWeakly(AVPlayerItem.Status.self, #keyPath(AVPlayerItem.status), options: [.initial, .new])
            .compactMap { $0 }
            .map { $0 == .unknown }
            .asDriverOnErrorJustComplete()
    }

    var readyToPlay: Driver<Void> {
        base.rx.observeWeakly(AVPlayerItem.Status.self, #keyPath(AVPlayerItem.status), options: [.initial, .new])
            .compactMap { $0 }
            .filter { $0 == .readyToPlay }
            .mapToVoid()
            .asDriverOnErrorJustComplete()
    }

    var playbackBufferEmpty: Driver<Bool> {
        base.rx.observe(Bool.self, #keyPath(AVPlayerItem.isPlaybackBufferEmpty), options: [.initial, .new], retainSelf: false)
            .compactMap { $0 }
            .asDriverOnErrorJustComplete()
    }

    var playbackBufferLikelyToKeepUp: Driver<Bool> {
        base.rx.observe(Bool.self, #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp), options: [.new], retainSelf: false)
            .compactMap { $0 }
            .distinctUntilChanged()
            .asDriverOnErrorJustComplete()
    }

    var playbackBufferFull: Driver<Bool> {
        base.rx.observe(Bool.self, #keyPath(AVPlayerItem.isPlaybackBufferFull), options: [.new], retainSelf: false)
            .compactMap { $0 }
            .asDriverOnErrorJustComplete()
    }

    func seek(to seekTime: CMTime) -> Driver<Bool> {
        Observable.create { observer in

            base.seek(to: seekTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero) { completed in
                observer.onNext(completed)
            }
            return Disposables.create()
        }.asDriverOnErrorJustComplete()
    }
}
