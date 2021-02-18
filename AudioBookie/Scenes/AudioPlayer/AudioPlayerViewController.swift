//
//  AudioPlayerViewController.swift
//  AudioBookie
//
//  Created by Justin on 2021-01-27.
//

import AVKit
import Foundation
import Kingfisher
import MediaPlayer
import RxCocoa
import RxKingfisher
import RxSwift
import Then
import UIKit

class AudioPlayerViewController: UIViewController {

    private let viewModel: AudioPlayerViewModelType
    private let disposeBag = DisposeBag()
    private let audioPlayerView = AudioPlayerView()
    private let player = AVPlayer().then {
        $0.automaticallyWaitsToMinimizeStalling = false
    }

    required init(viewModel: AudioPlayerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = audioPlayerView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        setupAudioSession()
        view.backgroundColor = Resources.Appearance.Color.viewBackground
        guard let currentItem = player.currentItem else { return }
        currentItem.preferredForwardBufferDuration = 10
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
    }

    private func bindViewModel() {

        // MARK: PlayingInfoCenter setup

        let playingInfoCenter = MPNowPlayingInfoCenter.default()

        // giving default empty values

        let songInfo: [String: Any] = [:]
        MPNowPlayingInfoCenter.default().nowPlayingInfo = songInfo

        // MARK: RemoteCommandCenter setup

        let remoteCommandCenter = MPRemoteCommandCenter.shared()

        remoteCommandCenter.togglePlayPauseCommand.isEnabled = true
        remoteCommandCenter.changePlaybackPositionCommand.isEnabled = true

        let skipBackwardCommand = remoteCommandCenter.skipBackwardCommand
        skipBackwardCommand.isEnabled = true
        skipBackwardCommand.preferredIntervals = [15]

        let skipForwardCommand = remoteCommandCenter.skipForwardCommand
        skipForwardCommand.isEnabled = true
        skipForwardCommand.preferredIntervals = [15]

        // MARK: Inputs

        let itemDidPlayToEndTime = player.rx.itemDidPlayToEndTime.asDriverOnErrorJustComplete()
        let input = AudioPlayerViewModelInput(itemDidPlayToEndTime: itemDidPlayToEndTime)

        // MARK: Outputs

        let output = viewModel.transform(input: input)

        // MARK: Set URL and play

        output.streamURL
            .compactMap { $0 }
            .drive(player.rx.replaceItem)
            .disposed(by: disposeBag)

        output.streamURL
            .mapTo(0)
            .drive(onNext: { _ in
                MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = 0
            })
            .disposed(by: disposeBag)

        // MARK: Change icon when last chapter did end playing

        output.endOfChapters
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.audioPlayerView.playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            })
            .disposed(by: disposeBag)

        // MARK: UI Setup for popupItem, remote and audiplayerView

        output.chapterTitle
            .drive(playingInfoCenter.rx.titleLabel)
            .disposed(by: disposeBag)

        output.chapterTitle
            .drive(popupItem.rx.title)
            .disposed(by: disposeBag)

        output.bookTitle
            .drive(playingInfoCenter.rx.artistLabel)
            .disposed(by: disposeBag)

        output.bookTitle
            .drive(popupItem.rx.subtitle)
            .disposed(by: disposeBag)

        let bookCover = output.cover
            .flatMap { url -> Driver<KFCrossPlatformImage> in
                let defaultImage = UIImage(imageLiteralResourceName: "librivoxCover" )
                guard let url = url, let makeURL = URL(string: url) else { return .just(defaultImage) }
                return KingfisherManager.shared.rx.retrieveImage(with: makeURL).asDriver(onErrorJustReturn: defaultImage)
            }

        bookCover
            .drive(playingInfoCenter.rx.artwork)
            .disposed(by: disposeBag)

        bookCover
            .drive(popupItem.rx.image)
            .disposed(by: disposeBag)

        bookCover
            .drive(audioPlayerView.bookCoverImageView.rx.image)
            .disposed(by: disposeBag)

        // Get currentItem duration in seconds

        let itemDuration = player.rx.currentItem
            .flatMap(\.rx.readyToPlay)
            .withLatestFrom(player.rx.currentItem)
            .map(\.asset.duration.seconds)

        player.rx.currentItem
            .flatMap(\.rx.readyToPlay)
            .withLatestFrom(player.rx.currentItem)
            .map { currentItem -> Double in
                let currentTime = currentItem.currentTime().seconds
                return currentTime
            }.drive(onNext: { value in
                MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = value
            })
            .disposed(by: disposeBag)

        // Update lock screen playback duration Label when ready to play

        itemDuration
            .debug()
            .drive(playingInfoCenter.rx.playbackDurationLabel)
            .disposed(by: disposeBag)

        // update playerView totalTime label

        itemDuration
            .map { $0.formatToTimeString() }
            .drive(audioPlayerView.totalTimeLabel.rx.text)
            .disposed(by: disposeBag)

        let durationSliderValue = audioPlayerView.durationSlider.rx.value.asDriver()

        // MARK: Current item loading

        let itemIsLoading = player.rx.currentItem
            .flatMap(\.rx.loading)

        itemIsLoading
            .filter { $0 == true }
            .mapTo("--:--")
            .drive(audioPlayerView.elapsedTimeLabel.rx.text,
                   audioPlayerView.totalTimeLabel.rx.text)
            .disposed(by: disposeBag)

        itemIsLoading
            .filter { $0 == true }
            .mapTo(0)
            .drive(audioPlayerView.durationSlider.rx.value)
            .disposed(by: disposeBag)

        itemIsLoading
            .drive(audioPlayerView.activityIndicator.rx.isAnimating, audioPlayerView.durationSlider.rx.userInteractionIsDisabled)
            .disposed(by: disposeBag)

        let itemIsReadyToPlay = player.rx.currentItem
            .flatMap(\.rx.readyToPlay)

        itemIsReadyToPlay
            .withLatestFrom(player.rx.currentItem)
            .map { currentItem -> String in
                let currentTime = currentItem.currentTime().seconds
                return currentTime.formatToTimeString()
            }.drive(audioPlayerView.elapsedTimeLabel.rx.text)
            .disposed(by: disposeBag)

        //  Handle play pause state and button images

        let remotePlayPauseCommand = remoteCommandCenter.rx.playPauseCommand
            .asDriverOnErrorJustComplete()

        let playPauseButtonTap = audioPlayerView.playPauseButton.rx.tap
            .asDriver()

        Driver.merge(remotePlayPauseCommand, playPauseButtonTap)
            .withLatestFrom(player.rx.timeControlStatus)
            .drive(player.rx.handlePlayPause, audioPlayerView.rx.setPlayPauseButtonImage)
            .disposed(by: disposeBag)

        // Handle remote control center play and pause rate
        // Prevents lock screen slider skips and syncs with playback position

        Driver.merge(remotePlayPauseCommand, playPauseButtonTap)
            .withLatestFrom(player.rx.timeControlStatus)
            .drive(onNext: { status in
                switch status {
                    case .playing:
                        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
                    case .paused, .waitingToPlayAtSpecifiedRate:
                        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = 0.0
                    @unknown default:
                        break
                }
            }).disposed(by: disposeBag)

        // Convert slider value to elapsed time

        let durationSliderValueToElapsedTime = durationSliderValue
            .withLatestFrom(itemDuration) { ($0, $1) }
            .map { sliderValue, duration -> Double in
                Float64(sliderValue) * duration
            }

        // Update elapsedTimeLabel text

        durationSliderValueToElapsedTime
            .map { $0.formatToTimeString() }
            .drive(audioPlayerView.elapsedTimeLabel.rx.text)
            .disposed(by: disposeBag)

        // Update lock screen elapsed time value

        durationSliderValueToElapsedTime
            .drive(onNext: { value in
                MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = value
            })
            .disposed(by: disposeBag)

        // Cancel previous seeks on touchdown to prevent slider jumps

        audioPlayerView.durationSlider.rx
            .controlEvent(.touchDown)
            .asDriver()
            .withLatestFrom(player.rx.currentItem)
            .map { currentItem in
                currentItem.cancelPendingSeeks()
            }.drive()
            .disposed(by: disposeBag)

        let seekingSubject = BehaviorSubject(value: false)

        // MARK: AudioplayerView slider seeking event

        audioPlayerView.durationSlider.rx
            .controlEvent([.touchUpInside, .touchUpOutside, .touchCancel])
            .asDriver()
            .withLatestFrom(durationSliderValue)
            .withLatestFrom(itemDuration) { ($0, $1) }
            .map { sliderValue, duration -> CMTime in
                let seekTime = Float64(sliderValue) * duration
                return CMTimeMakeWithSeconds(seekTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            }.withLatestFrom(player.rx.timeControlStatus) { ($0, $1) }
            .drive(onNext: { [weak self] seekTime, status in
                guard let self = self else { return }
                guard let currentItem = self.player.currentItem else { return }
                switch status {
                    case .paused:
                        currentItem.seek(to: seekTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero) { completed in
                            seekingSubject.onNext(!completed)
                        }
                    case .playing:
                        self.player.pause()
                        currentItem.seek(to: seekTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero) { completed in
                            seekingSubject.onNext(!completed)
                            self.player.play()
                        }
                    default:
                        break
                }
            }).disposed(by: disposeBag)

        // MARK: RemoteCommandCenter slider seek event

        remoteCommandCenter.rx.changePlaybackPositionCommand.asDriverOnErrorJustComplete()
            .map { seekTime in
                CMTimeMakeWithSeconds(seekTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            }
            .withLatestFrom(player.rx.timeControlStatus) { ($0, $1) }
            .drive(onNext: { [weak self] seekTime, status in
                guard let self = self else { return }
                guard let currentItem = self.player.currentItem else { return }
                switch status {
                    case .paused, .waitingToPlayAtSpecifiedRate:
                        currentItem.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero, completionHandler: nil)
                    case .playing:
                        self.player.pause()
                        currentItem.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero) { _ in
                            self.player.play()
                        }
                    @unknown default:
                        break
                }
            }).disposed(by: disposeBag)

        // MARK: Skip forward 15 seconds

        let remoteSkipForwardCommand = remoteCommandCenter.rx.skipForwardCommand
            .asDriverOnErrorJustComplete()

        let skipForwardButtonTap = audioPlayerView.skipForwardButton.rx.tap
            .asDriver()

        Driver.merge(remoteSkipForwardCommand, skipForwardButtonTap)
            .withLatestFrom(player.rx.currentItem)
            .map { currentItem -> CMTime in
                let toCMTime = CMTimeMake(value: 15, timescale: 1)
                let seekTime = CMTimeAdd(currentItem.currentTime(), toCMTime)
                return seekTime
            }.withLatestFrom(player.rx.timeControlStatus) { ($0, $1) }
            .drive(onNext: { [weak self] seekTime, status in
                guard let self = self else { return }
                guard let currentItem = self.player.currentItem else { return }
                switch status {
                    case .paused:
                        currentItem.seek(to: seekTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero, completionHandler: nil)
                    case .playing:
                        self.player.pause()
                        currentItem.seek(to: seekTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero) { _ in
                            self.player.play()
                        }
                    default:
                        break
                }
            }).disposed(by: disposeBag)

        // MARK: Skip backward 15 seconds

        let remoteSkipBackwardCommand = remoteCommandCenter.rx.skipBackwardCommand
            .asDriverOnErrorJustComplete()

        let skipBackwardButtonTap = audioPlayerView.skipBackwardButton.rx.tap
            .asDriver()

        Driver.merge(remoteSkipBackwardCommand, skipBackwardButtonTap)
            .withLatestFrom(player.rx.currentItem)
            .map { currentItem -> CMTime in
                let toCMTime = CMTimeMake(value: -15, timescale: 1)
                let seekTime = CMTimeAdd(currentItem.currentTime(), toCMTime)
                return seekTime
            }.withLatestFrom(player.rx.timeControlStatus) { ($0, $1) }
            .drive(onNext: { [weak self] seekTime, status in
                guard let self = self else { return }
                guard let currentItem = self.player.currentItem else { return }
                switch status {
                    case .paused:
                        currentItem.seek(to: seekTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero, completionHandler: nil)
                    case .playing:
                        self.player.pause()
                        currentItem.seek(to: seekTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero) { _ in
                            self.player.play()
                        }
                    default:
                        break
                }
            }).disposed(by: disposeBag)

        // Take touchdown event of slider to stop playback position observable while sliding

        let onSliderTouchDown = audioPlayerView.durationSlider.rx
            .controlEvent([.touchDown])
            .asDriver()
            .mapTo(true)

        let seeking = Driver.merge(onSliderTouchDown, seekingSubject.asDriverOnErrorJustComplete())
            .distinctUntilChanged()

        // MARK: Observing playback position

        // Skipping while currentItem is loading
        // Skipping while seeking to prevent jumps

        let playbackPosition = player.rx.playbackPosition(updateInterval: 1, updateQueue: .main)
            .skip(if: itemIsLoading)
            .skip(if: seeking)
            .distinctUntilChanged()

        // Update lock screen elapsedTimeLabel

        playbackPosition
            .drive(playingInfoCenter.rx.elapsedTimeLabel)
            .disposed(by: disposeBag)

        // Update audioPlayerView elapsedTimeLabel

        playbackPosition
            .map { $0.formatToTimeString() }
            .drive(audioPlayerView.elapsedTimeLabel.rx.text)
            .disposed(by: disposeBag)

        // Update audioPlayerView durationSlider value

        playbackPosition
            .withLatestFrom(itemDuration) { ($0, $1) }
            .map { playbackPosition, itemDuration in
                Float(playbackPosition / itemDuration)
            }.drive(audioPlayerView.durationSlider.rx.value, popupItem.rx.progress)
            .disposed(by: disposeBag)
    }
}

extension Reactive where Base: AudioPlayerView {
    var setPlayPauseButtonImage: Binder<AVPlayer.TimeControlStatus> {
        Binder(base) { view, status in
            switch status {
                case .playing, .waitingToPlayAtSpecifiedRate:
                    view.playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
                case .paused:
                    view.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
                @unknown default:
                    break
            }
        }
    }
}
