//
//  AudioPlayerView.swift
//  AudioBookie
//
//  Created by Justin on 2021-01-27.
//

import MarqueeLabel
import Then
import UIKit

class AudioPlayerView: UIView {

    // MARK: Book cover

    let bookCoverView = UIView()

    let bookCoverImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
        $0.clipsToBounds = true
    }

    // MARK: Title and author

    let titleAndAuthorView = UIView()

    let chapterTitleLabel = MarqueeLabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 22.0)
        $0.text = "Chapter label"
    }

    let authorLabel = MarqueeLabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 19.0)
        $0.text = "Author Label"
    }

    lazy var chapterInformationStackView = UIStackView(arrangedSubviews: [chapterTitleLabel, authorLabel]).then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.spacing = 10
    }

    // MARK: Slider and time labels

    let sliderAndTimeLabelsView = UIView()

    let durationSlider = UISlider().then {
        $0.minimumTrackTintColor = .systemPurple
    }

    let elapsedTimeLabel = UILabel().then {
        $0.text = "--:--"
        $0.font = UIFont.boldSystemFont(ofSize: 14.0)
        $0.alpha = 0.8
    }

    let totalTimeLabel = UILabel().then {
        $0.text = "--:--"
        $0.font = UIFont.boldSystemFont(ofSize: 14.0)
        $0.alpha = 0.8
    }

    let activityIndicator = UIActivityIndicatorView(style: .gray)

    lazy var timeLabelsStackView = UIStackView(arrangedSubviews: [elapsedTimeLabel, totalTimeLabel]).then {
        $0.distribution = .equalSpacing
    }

    lazy var sliderAndTimeLabelsStackView = UIStackView(arrangedSubviews: [durationSlider, timeLabelsStackView]).then {
        $0.axis = .vertical
    }

    // MARK: Player controls

    let controlsView = UIView()

    let playPauseButton = UIButton(type: .system).then {
        $0.setImage(#imageLiteral(resourceName: "pause").withRenderingMode(.alwaysTemplate), for: .normal)
        if #available(iOS 13.0, *) {
            $0.tintColor = .label
        } else {
            $0.tintColor = .black
        }
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
        $0.imageView?.contentMode = .scaleAspectFit
    }

    let skipForwardButton = UIButton(type: .system).then {
        $0.setImage(#imageLiteral(resourceName: "fastforward15").withRenderingMode(.alwaysTemplate), for: .normal)
        if #available(iOS 13.0, *) {
            $0.tintColor = .label
        } else {
            $0.tintColor = .black
        }
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
        $0.imageView?.contentMode = .scaleAspectFit
    }

    let skipBackwardButton = UIButton(type: .system).then {
        $0.setImage(#imageLiteral(resourceName: "rewind15").withRenderingMode(.alwaysTemplate), for: .normal)
        if #available(iOS 13.0, *) {
            $0.tintColor = .label
        } else {
            $0.tintColor = .black
        }
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
        $0.imageView?.contentMode = .scaleAspectFit
    }

    let miniPlayPauseButton = UIButton().then {
        $0.setImage(#imageLiteral(resourceName: "play").withRenderingMode(.alwaysTemplate), for: .normal)
        if #available(iOS 13.0, *) {
            $0.tintColor = .label
        } else {
            $0.tintColor = .black
        }
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
        $0.imageView?.contentMode = .scaleAspectFit
    }

    let miniSkipBackWardButton = UIButton(type: .system).then {
        $0.setImage(#imageLiteral(resourceName: "rewind15").withRenderingMode(.alwaysTemplate), for: .normal)
        if #available(iOS 13.0, *) {
            $0.tintColor = .label
        } else {
            $0.tintColor = .black
        }
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
        $0.imageView?.contentMode = .scaleAspectFit
    }

    lazy var controlButtonsStackView = UIStackView(arrangedSubviews: [skipBackwardButton, playPauseButton, skipForwardButton]).then {
        $0.distribution = .equalCentering
        $0.spacing = 36
    }

    lazy var skipBackwardButtonItem = UIBarButtonItem(customView: miniPlayPauseButton)

    lazy var playPauseButtonItem = UIBarButtonItem(customView: miniPlayPauseButton)

    // MARK: Main views stack

    lazy var mainStackView = UIStackView(arrangedSubviews: [bookCoverView, titleAndAuthorView, sliderAndTimeLabelsView, controlsView]).then {
        $0.axis = .vertical
        $0.distribution = .fillProportionally
    }

    init() {
        super.init(frame: .zero)
        backgroundColor = Resources.Appearance.Color.viewBackground
        setupMainStackViewLayout()
        setupBookCoverView()
        setupButtonControlsView()
        setupSliderAndTimeLabelsView()
        setupTitleAndAuthorView()
    }

    func setupBookCoverView() {
        bookCoverImageView.add(to: bookCoverView)
        bookCoverImageView.centerXAnchor.constraint(equalTo: bookCoverView.centerXAnchor).isActive = true
        bookCoverImageView.centerYAnchor.constraint(equalTo: bookCoverView.centerYAnchor).isActive = true
        bookCoverView.heightAnchor.constraint(equalToConstant: 275).isActive = true
        bookCoverView.widthAnchor.constraint(equalToConstant: 275).isActive = true
    }

    func setupTitleAndAuthorView() {
        chapterInformationStackView.add(to: titleAndAuthorView)
        chapterInformationStackView.centerXAnchor.constraint(equalTo: titleAndAuthorView.centerXAnchor).isActive = true
        chapterInformationStackView.centerYAnchor.constraint(equalTo: titleAndAuthorView.centerYAnchor, constant: UIScreen.main.bounds.height * 0.01).isActive = true
        chapterInformationStackView.widthAnchor.constraint(equalTo: titleAndAuthorView.widthAnchor).isActive = true
    }

    func setupSliderAndTimeLabelsView() {
        sliderAndTimeLabelsStackView.add(to: sliderAndTimeLabelsView)
        sliderAndTimeLabelsStackView.centerYAnchor.constraint(equalTo: sliderAndTimeLabelsView.centerYAnchor).isActive = true
        sliderAndTimeLabelsStackView.leadingAnchor.constraint(equalTo: sliderAndTimeLabelsView.leadingAnchor).isActive = true
        sliderAndTimeLabelsStackView.trailingAnchor.constraint(equalTo: sliderAndTimeLabelsView.trailingAnchor).isActive = true
    }

    func setupButtonControlsView() {
        controlButtonsStackView.add(to: controlsView)
        controlButtonsStackView.centerXAnchor.constraint(equalTo: controlsView.centerXAnchor).isActive = true
        controlButtonsStackView.centerYAnchor.constraint(equalTo: controlsView.centerYAnchor).isActive = true
    }

    func setupMainStackViewLayout() {
        mainStackView.do {
            $0.add(to: self)
            $0.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: UIScreen.main.bounds.height * 0.065).isActive = true
            $0.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: UIScreen.main.bounds.height * -0.05).isActive = true
            $0.leadingAnchor.constraint(equalTo: leadingAnchor, constant: UIScreen.main.bounds.height * 0.03).isActive = true
            $0.trailingAnchor.constraint(equalTo: trailingAnchor, constant: UIScreen.main.bounds.height * -0.03).isActive = true
        }

        bookCoverView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.5).isActive = true
        sliderAndTimeLabelsView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.1).isActive = true
        titleAndAuthorView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.12).isActive = true
        controlsView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.15).isActive = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

