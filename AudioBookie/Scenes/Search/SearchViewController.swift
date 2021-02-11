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
        bindViewModel()
        configureViews()
    }

    private func configureViews() {
        let didBeginEditing = searchController.searchBar.rx.textDidBeginEditing.asDriver().mapTo(true)
        let didEndEditing = searchController.searchBar.rx.cancelButtonClicked.asDriver().mapTo(false)
        let isEditing = Driver.merge(didBeginEditing, didEndEditing).startWith(false)

        let v = UIView()
        v.backgroundColor = Resources.Appearance.Color.viewBackground

        isEditing
            .drive(onNext: { [weak self] editing in
                guard let self = self else { return }
                if editing {
                    v.removeFromSuperview()
                    self.collectionView.add(to: self.view)
                    self.collectionView.pinToEdges(of: self.view)
                } else {
                    self.collectionView.removeFromSuperview()
                    v.add(to: self.view)
                    v.pinToEdges(of: self.view)
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

        let searchText = searchController
            .searchBar
            .rx
            .text
            .compactMap { $0 }
            .filter { $0.isEmpty == false }
            .throttle(.milliseconds(600), scheduler: MainScheduler.instance)
            .asDriverOnErrorJustComplete()

        let cancelButtonClicked = searchController
            .searchBar
            .rx
            .cancelButtonClicked
            .asDriverOnErrorJustComplete()

        let reachedBottom = collectionView
            .rx
            .reachedBottom(offset: 10)
            .asDriverOnErrorJustComplete()

        let input = SearchViewModelInput(searchText: searchText,
                                         textDidChange: textDidChange,
                                         cancelButtonClicked: cancelButtonClicked,
                                         reachedBottom: reachedBottom)

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
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func setupCollectionView() {

        collectionView.do {
            $0.backgroundColor = Resources.Appearance.Color.viewBackground
            $0.register(cellType: BookCell.self)
            $0.showsVerticalScrollIndicator = false
            $0.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: -16)
        }

        // FlowLayout setup

        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        flowLayout.do {
            $0.itemSize = CGSize(width: view.frame.width, height: 72)
            $0.minimumLineSpacing = 16
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
}
