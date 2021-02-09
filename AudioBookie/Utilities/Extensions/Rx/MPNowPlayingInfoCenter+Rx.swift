//
//  MPNowPlayingInfo+Rx.swift
//  AudioBookie
//
//  Created by Justin on 2021-02-04.
//

import MediaPlayer
import RxCocoa
import RxSwift

extension Reactive where Base: MPNowPlayingInfoCenter {

    var playbackDurationLabel: Binder<Double> {
        Binder(base) { center, duration in
            center.nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = duration
        }
    }

    var elapsedTimeLabel: Binder<Double> {
        Binder(base) { center, time in
            center.nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = time
        }
    }

    var artistLabel: Binder<String> {
        Binder(base) { center, text in
            center.nowPlayingInfo?[MPMediaItemPropertyArtist] = text
        }
    }

    var titleLabel: Binder<String> {
        Binder(base) { center, text in
            center.nowPlayingInfo?[MPMediaItemPropertyTitle] = text
        }
    }

    var artwork: Binder<UIImage> {
        Binder(base) { center, image in
            let artworkItem = MPMediaItemArtwork(boundsSize: .zero) { _ -> UIImage in
                image
            }
            center.nowPlayingInfo?[MPMediaItemPropertyArtwork] = artworkItem
        }
    }
}
