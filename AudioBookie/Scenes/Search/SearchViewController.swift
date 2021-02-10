//
//  SearchViewController.swift
//  AudioBookie
//
//  Created by Justin on 2021-01-24.
//

import RxCocoa
import RxSwift
import Then
import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate {

    private let disposeBag = DisposeBag()
    private let viewModel: SearchViewModelType
    private let searchController = UISearchController(searchResultsController: nil)
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    init(viewModel: SearchViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Resources.Appearance.Color.viewBackground
        setupCollectionView()
        setupNavigationBar()
        setupSearchController()
        hideKeyboardWhenTappedAround()
        bindViewModelInputs()
        bindViewModelOutputs()
    }

    private func bindViewModelInputs() {

        searchController
            .searchBar
            .rx
            .text
            .compactMap { $0 }
            .filter { $0.isEmpty == false }
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .debug()
            .bind(to: viewModel.input.searchText)
            .disposed(by: disposeBag)
    }

    private func bindViewModelOutputs() {

        viewModel
            .output
            .searchResult
            .drive(onNext: { value in
                print(value)
            }).disposed(by: disposeBag)
    }

    private func setupNavigationBar() {
        navigationItem.do {
            $0.hidesSearchBarWhenScrolling = false
            $0.searchController = searchController
            $0.title = "Search"
        }
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.do {
            $0.backgroundColor = Resources.Appearance.Color.viewBackground
            $0.register(cellType: BookCell.self)
            $0.showsVerticalScrollIndicator = false
            $0.add(to: view)
            $0.pinToEdges(of: view)
            $0.contentInset = UIEdgeInsets(top: 10, left: UIScreen.main.bounds.width * 0.058, bottom: 20, right: UIScreen.main.bounds.width * -0.058)
        }
    }

    private func setupSearchController() {

        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.isTranslucent = true
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.placeholder = "All books"
        searchController.searchBar.returnKeyType = .done
        searchController.searchBar.enablesReturnKeyAutomatically = false

        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.systemPurple,
            .font: UIFont.systemFont(ofSize: 17)
        ]

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
        .init(width: view.frame.width, height: 72)
    }
}

extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        10
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ofType: BookCell.self, for: indexPath)

        return cell
    }
}
