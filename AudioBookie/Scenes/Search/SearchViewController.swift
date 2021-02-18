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

class SearchViewController: UIViewController {

    private let disposeBag = DisposeBag()
    private let viewModel: SearchViewModelType
    private let searchController = UISearchController(searchResultsController: nil)
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    private let landingView = UIView()
    private let searchEmptyView = UIView()

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
        bindViewModel()
        configureViews()
    }

    func addCollectionView() {
        collectionView.add(to: view)
        collectionView.pinToEdges(of: view)
    }

    func addLandingView() {
        landingView.backgroundColor = Resources.Appearance.Color.viewBackground
        landingView.add(to: view)
        landingView.pinToEdges(of: view)
    }

    func addSearchEmptyView() {
        searchEmptyView.backgroundColor = .blue
        searchEmptyView.add(to: view)
        searchEmptyView.pinToEdges(of: view)
    }

    func removeViewsFromSuperview() {
        view.subviews.forEach { $0.removeFromSuperview() }
    }

    private func configureViews() {

        let didBeginEditing = searchController.searchBar.rx.textDidBeginEditing.asDriver().mapTo(true)
        let searchCancelButtonClicked = searchController.searchBar.rx.cancelButtonClicked.asDriver().mapTo(false)
        let isSearching = Driver.merge(didBeginEditing, searchCancelButtonClicked).startWith(false)

        isSearching
            .drive(onNext: { [weak self] searching in
                guard let self = self else { return }
                self.removeViewsFromSuperview()
                if searching {
                    self.addCollectionView()
                } else {
                    self.addLandingView()
                }

            }).disposed(by: disposeBag)
    }

    private func bindViewModel() {

        let keyboardSearchButtonClicked = searchController.searchBar.rx.searchButtonClicked.asDriver()
        let willBeginDragging = collectionView.rx.willBeginDragging.asDriver()

        Driver.merge(keyboardSearchButtonClicked, willBeginDragging)
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                if self.searchController.searchBar.isFirstResponder {
                    self.searchController.searchBar.resignFirstResponder()
                }
            })
            .disposed(by: disposeBag)

        let textDidChange = searchController
            .searchBar
            .rx
            .delegate
            .methodInvoked(#selector(UISearchBarDelegate.searchBar(_:textDidChange:)))
            .map { _ in }
            .asDriverOnErrorJustComplete()

        let searchCancelButtonTapped = searchController
            .searchBar
            .rx
            .cancelButtonClicked
            .asDriver()

        let didBeginEditing = searchController.searchBar.rx.textDidBeginEditing.asDriver().mapTo(true)
        let didEndEditing = searchController.searchBar.rx.textDidEndEditing.asDriver().mapTo(false)
        let searchBarActive = Driver.merge(didBeginEditing, didEndEditing).startWith(true)

        searchController.searchBar
            .rx
            .textDidBeginEditing
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.collectionView.contentOffset.y = -144
            }).disposed(by: disposeBag)

        let searchText = searchController
            .searchBar
            .rx
            .text
            .debounce(.milliseconds(400), scheduler: MainScheduler.instance)
            .compactMap { $0 }
            .filter { $0.isEmpty == false }
            .asDriverOnErrorJustComplete()
            .take(if: searchBarActive)

        let textIsEmpty = searchController
            .searchBar
            .rx
            .text
            .compactMap { $0 }
            .filter { $0.isEmpty }
            .mapToVoid()
            .asDriverOnErrorJustComplete()

        let textNotEmpty = searchController
            .searchBar
            .rx
            .text
            .compactMap { $0 }
            .filter { $0.count > 0 }
            .asDriverOnErrorJustComplete()
            .mapTo(false)

        let reachedBottom = collectionView
            .rx
            .reachedBottom(offset: 10)
            .startWith(true)
            .asDriverOnErrorJustComplete()

        let input = SearchViewModelInput(searchText: searchText,
                                         textIsEmpty: textIsEmpty,
                                         textNotEmpty: textNotEmpty,
                                         textDidChange: textDidChange,
                                         reachedBottom: reachedBottom,
                                         searchCancelButtonTapped: searchCancelButtonTapped)

        let output = viewModel.transform(input: input)

        output
            .books
            .drive(collectionView.rx.items) { collectionView, row, book in
                let indexPath = IndexPath(row: row, section: 0)
                let cell = collectionView.dequeueReusableCell(ofType: BookCell.self, for: indexPath)
                cell.titleLabel.text = book.title
                cell.subtitleLabel.text = book.author
                return cell
            }
            .disposed(by: disposeBag)

        output
            .loading
            .drive()
            .disposed(by: disposeBag)
    }

    private func setupNavigationBar() {
        navigationItem.do {
            $0.hidesSearchBarWhenScrolling = false
            $0.searchController = searchController
            $0.title = "Search"
        }
        navigationController?.navigationBar.layoutMargins.left = 16
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func setupCollectionView() {

        collectionView.do {
            $0.backgroundColor = Resources.Appearance.Color.viewBackground
            $0.register(cellType: BookCell.self)
            $0.showsVerticalScrollIndicator = false
            $0.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: -16)
        }

        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        flowLayout.do {
            $0.itemSize = CGSize(width: view.frame.width, height: 72)
            $0.minimumLineSpacing = 16
        }
    }

    private func setupSearchController() {

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
}
