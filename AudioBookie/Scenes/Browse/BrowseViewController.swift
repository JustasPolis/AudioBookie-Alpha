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

class BrowseViewController: UIViewController, UICollectionViewDelegateFlowLayout {

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
        extendedLayoutIncludesOpaqueBars = true
        setupCollectionView()
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        flowLayout.itemSize = CGSize(width: view.frame.width, height: 350)

        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = nil
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(cellType: BrowseCollectionViewCell.self)
        collectionView.register(cellType: GenresCollectionView.self)
        collectionView.register(cellType: BooksCollectionView.self)
        collectionView.registerHeader(type: SectionHeader.self)
        collectionView.registerHeader(type: SectionHeader1.self)

        let dataSource = BrowseCollectionViewDataSource.dataSource()

        let input = BrowseViewModelInput()
        let output = viewModel.transform(input: input)

        output.items
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        if section == 0 {
            return CGSize(width: collectionView.frame.width, height: 120)
        }

        return CGSize(width: collectionView.frame.width, height: 75)
    }
}

extension Date {
    var millisecondsSince1970: Int {
        Int(timeIntervalSince1970 * 1000)
    }
}
