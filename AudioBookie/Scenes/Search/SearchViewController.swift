//
//  SearchViewController.swift
//  AudioBookie
//
//  Created by Justin on 2021-01-24.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate {

    let searchController = UISearchController(searchResultsController: nil)

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.add(to: view)
        collectionView.pinToEdges(of: view)
        collectionView.backgroundColor = Resources.Appearance.Color.viewBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(cellType: UICollectionViewCell.self)
        navigationItem.hidesSearchBarWhenScrolling = false

        collectionView.showsVerticalScrollIndicator = false

        hideKeyboardWhenTappedAround()
        navigationItem.searchController = searchController
        navigationItem.title = "Search"
        navigationController?.navigationBar.prefersLargeTitles = true
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.isTranslucent = true
        searchController.hidesNavigationBarDuringPresentation = true
        view.backgroundColor = Resources.Appearance.Color.viewBackground
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.systemPurple,
            .font: UIFont.systemFont(ofSize: 17)
        ]
        searchController.searchBar.placeholder = "All books"
        searchController.searchBar.returnKeyType = .done
        searchController.searchBar.enablesReturnKeyAutomatically = false
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchController.searchBar.endEditing(true)
        searchController.isActive = false
    }

    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        searchController.searchBar.endEditing(true)
        searchController.isActive = false
    }
}

extension SearchViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: view.frame.width, height: 150)
    }
}

extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        10
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ofType: UICollectionViewCell.self, for: indexPath)
        cell.backgroundColor = .blue
        return cell
    }
}
