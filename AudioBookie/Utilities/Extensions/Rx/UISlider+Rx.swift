//
//  UISlider+Rx.swift
//  AudioBookie
//
//  Created by Justin on 2021-01-30.
//

import RxSwift
import RxCocoa
import UIKit


extension Reactive where Base: UISlider {

    var userInteractionIsDisabled: Binder<Bool> {
        Binder(base) { slider, loading in
            slider.isUserInteractionEnabled = !loading
        }
    }
}
