//
//  SceneCoordinator.swift
//  AudioBookie
//
//  Created by Justin on 2021-01-22.
//

import UIKit

protocol SceneCoordinatorType {
    init()

    func transition(to scene: TargetScene)
    func pop(animated: Bool)
}

class SceneCoordinator: NSObject, SceneCoordinatorType {

    static var shared: SceneCoordinator!

    private let window: UIWindow
    private var currentViewController: UIViewController {
        didSet {
            currentViewController.navigationController?.delegate = self
            currentViewController.tabBarController?.delegate = self
        }
    }

    override required init() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
        currentViewController = window.rootViewController ?? UIViewController()
        super.init()
    }

    static func actualViewController(for viewController: UIViewController) -> UIViewController {
        var controller = viewController
        if let tabBarController = controller as? UITabBarController {
            guard let selectedViewController = tabBarController.selectedViewController else {
                return tabBarController
            }
            controller = selectedViewController

            return actualViewController(for: controller)
        }

        if let navigationController = viewController as? UINavigationController {
            controller = navigationController.viewControllers.first!

            return actualViewController(for: controller)
        }
        return controller
    }

    func transition(to scene: TargetScene) {
        switch scene.transition {
            case let .tabBar(tabBarController):
                guard let selectedViewController = tabBarController.selectedViewController else {
                    fatalError("Selected view controller doesn't exists")
                }
                currentViewController = SceneCoordinator.actualViewController(for: selectedViewController)
                window.rootViewController = tabBarController
            case let .root(viewController):
                currentViewController = SceneCoordinator.actualViewController(for: viewController)
                window.rootViewController = viewController
            case let .push(viewController):
                guard let navigationController = currentViewController.navigationController else {
                    fatalError("Can't push a view controller without a current navigation controller")
                }
                navigationController.pushViewController(SceneCoordinator.actualViewController(for: viewController), animated: true)

            case let .present(viewController):

                viewController.presentationController?.delegate = self

                currentViewController.present(viewController, animated: true) {
                    self.currentViewController = SceneCoordinator.actualViewController(for: viewController)
                }
            case let .presentPopup(viewController):
                guard let tabBarController = currentViewController.tabBarController else {
                    fatalError("Can't present popup without a tabBarController")
                }
                tabBarController.presentPopupBar(withContentViewController: viewController, openPopup: true, animated: true, completion: nil)
        }
    }

    func pop(animated: Bool) {

        if let presentingViewController = currentViewController.presentingViewController {
            currentViewController.dismiss(animated: animated) {
                self.currentViewController = SceneCoordinator.actualViewController(for: presentingViewController)
            }
        } else if let navigationController = currentViewController.navigationController {
            guard navigationController.popViewController(animated: animated) != nil else {
                fatalError("can't navigate back from \(currentViewController)")
            }
            currentViewController = SceneCoordinator.actualViewController(for: navigationController.viewControllers.last!)
        } else {
            fatalError("Not a modal, no navigation controller: can't navigate back from \(currentViewController)")
        }
    }
}

extension SceneCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        currentViewController = SceneCoordinator.actualViewController(for: viewController)
    }
}

extension SceneCoordinator: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        currentViewController = SceneCoordinator.actualViewController(for: viewController)
    }
}

extension SceneCoordinator: UIAdaptivePresentationControllerDelegate {
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        currentViewController = SceneCoordinator.actualViewController(for: presentationController.presentingViewController)
    }
}
