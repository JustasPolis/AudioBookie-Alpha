//
//  ViewController.swift
//  AudioBookie
//
//  Created by Justin on 2021-01-22.
//

import Alamofire
import RxCocoa
import RxDataSources
import RxSwift
import UIKit

class BrowseViewController: UIViewController {

    let disposeBag = DisposeBag()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let viewModel: BrowseViewModelType

    required init(viewModel: BrowseViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        bindViewModel()
        setupNavigationBar()
    }

    func setupNavigationBar() {
        navigationController?.navigationBar.layoutMargins.left = 16
        navigationController?.navigationBar.layoutMargins.bottom = 10
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Browse"
    }

    func bindViewModel() {
        let dataSource = BrowseCollectionViewDataSource.dataSource()

        let input = BrowseViewModelInput()
        let output = viewModel.transform(input: input)

        output.items
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

    func setupCollectionView() {
        view.addSubview(collectionView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        collectionView.backgroundColor = Resources.Appearance.Color.viewBackground
        collectionView.delegate = self
        collectionView.dataSource = nil
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(cellType: VerticalListCell.self)
        collectionView.register(cellType: BooksCollectionView.self)
        collectionView.registerHeader(type: SectionHeader.self)
    }
}

extension BrowseViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        CGSize(width: collectionView.frame.width, height: 75)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        if indexPath.section == 0 || indexPath.section == 1 {
            return CGSize(width: view.frame.width, height: 225)
        }

        return CGSize(width: view.frame.width, height: 42.5)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 3 {
            return UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
        }
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
