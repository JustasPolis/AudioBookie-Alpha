//
//  AppDelegate.swift
//  AudioBookie
//
//  Created by Justin on 2021-01-22.
//

import UIKit
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let sceneCoordinator = SceneCoordinator()
        SceneCoordinator.shared = sceneCoordinator
        sceneCoordinator.transition(to: Scene.root)

        return true
    }
}
