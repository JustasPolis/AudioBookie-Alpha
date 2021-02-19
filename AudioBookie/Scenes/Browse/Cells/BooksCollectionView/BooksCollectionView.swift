//
//  BooksCollectionView.swift
//  AudioBookie
//
//  Created by Justin on 2021-01-22.
//

import RxSwift
import Then
import UIKit

final class BooksCollectionView: UICollectionViewCell {

    private var disposeBag = DisposeBag()
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    var viewModel: BooksCollectionViewModelType? {
        didSet {
            bindViewModel()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCollectionView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    private func setupCollectionView() {

        collectionView.do {
            $0.register(cellType: BooksCollectionViewCell.self)
            $0.backgroundColor = Resources.Appearance.Color.viewBackground
            $0.showsHorizontalScrollIndicator = false
            $0.add(to: self)
            $0.pinToEdges(of: self)
        }

        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        flowLayout.do {
            $0.scrollDirection = .horizontal
            $0.itemSize = CGSize(width: frame.height - 60, height: frame.height)
            $0.sectionInset = UIEdgeInsets(top: 0, left: 16.0, bottom: 0, right: 16.0)
        }
    }

    private func bindViewModel() {

        guard let viewModel = viewModel else { return }
        // Inputs

        let bookSelected = collectionView.rx.modelSelected(Book.self).asDriver()
        let input = BooksCollectionViewModelInput(bookSelected: bookSelected)

        // Outputs

        let output = viewModel.transform(input: input)

        output.navigateToBookDetails
            .drive()
            .disposed(by: disposeBag)

        viewModel.books
            .drive(collectionView.rx.items) { collectionView, row, book in
                let indexPath = IndexPath(row: row, section: 0)
                let cell = collectionView.dequeueReusableCell(ofType: BooksCollectionViewCell.self, for: indexPath)
                cell.configure(with: book)
                return cell
            }
            .disposed(by: disposeBag)
    }
}
