//
//  Scene.swift
//  AudioBookie
//
//  Created by Justin on 2021-01-22.
//

import UIKit

protocol TargetScene {
    var transition: SceneTransitionType { get }
}

enum SceneTransitionType {
    case root(UIViewController)
    case push(UIViewController)
    case present(UIViewController)
    case tabBar(UITabBarController)
    case presentPopup(UIViewController)
}

enum Scene {
    case root
    case bookDetails(Book)
    case bookListByGenre(Genre)
    case audioPlayer(index: Int, book: Book)
}

extension Scene: TargetScene {
    var transition: SceneTransitionType {
        switch self {
            case .root:
                let network = Network()
                let networkService = NetworkService(network: network)
                // BrowseViewController init
                let browseViewModel = BrowseViewModel(networkService: networkService, sceneCoordinator: SceneCoordinator.shared)
                let browseViewController = UINavigationController(rootViewController: BrowseViewController(viewModel: browseViewModel))

                // SearchViewController init
                let searchViewModel = SearchViewModel()
                let searchViewController = UINavigationController(rootViewController: SearchViewController(viewModel: searchViewModel))

                // LibraryViewController init
                let libraryViewController = UINavigationController(rootViewController: LibraryViewController())

                // TabBarController init

                let browseTabBarItem = UITabBarItem(
                    title: "Browse",
                    image: #imageLiteral(resourceName: "browse"),
                    tag: 0
                )
                let libraryTabBarItem = UITabBarItem(
                    title: "Library",
                    image: #imageLiteral(resourceName: "downloads"),
                    tag: 1
                )
                let searchTabBarItem = UITabBarItem(
                    title: "Search",
                    image: #imageLiteral(resourceName: "search"),
                    tag: 2
                )

                browseViewController.tabBarItem = browseTabBarItem
                libraryViewController.tabBarItem = libraryTabBarItem
                searchViewController.tabBarItem = searchTabBarItem

                let tabBarController = TabBarController()
                tabBarController.tabBar.tintColor = .systemPurple
                tabBarController.viewControllers = [searchViewController, browseViewController, libraryViewController]

                // return
                return .tabBar(tabBarController)
            case .bookDetails(let book):
                let network = Network()
                let networkService = NetworkService(network: network)
                let viewModel = BookDetailsViewModel(sceneCoordinator: SceneCoordinator.shared, networkService: networkService)
                let viewController = BookDetailsViewController(viewModel: viewModel, book: book)
                return .push(viewController)
            case .bookListByGenre:
                let network = Network()
                _ = NetworkService(network: network)
                let viewController = BookListViewController()
                return .push(viewController)
            case .audioPlayer(let index, let book):
                let viewModel = AudioPlayerViewModel(startIndex: index, book: book)
                let viewController = AudioPlayerViewController(viewModel: viewModel)
                return .presentPopup(viewController)
        }
    }
}
