//
//  LanguagesCollectionView.swift
//  AudioBookie
//
//  Created by Justin on 2021-01-22.
//

import RxSwift
import Then
import UIKit

final class GenresCollectionView: UICollectionViewCell {

    private var disposeBag = DisposeBag()
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    var viewModel: GenresCollectionViewModelType! {
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

        // CollectionView setup

        collectionView.do {
            $0.register(cellType: UICollectionViewCell.self)
            $0.backgroundColor = .white
            $0.showsHorizontalScrollIndicator = false
            $0.add(to: self)
            $0.pinToEdges(of: self)
        }

        // FlowLayout setup

        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        flowLayout.do {
            $0.scrollDirection = .horizontal
            $0.itemSize = CGSize(width: frame.height, height: frame.height)
            $0.sectionInset = UIEdgeInsets(top: 0, left: 14.0, bottom: 0, right: 14.0)
        }
    }

    private func bindViewModel() {

        // Inputs

        let genreSelected = collectionView.rx.modelSelected(Genre.self).asDriver()
        let input = GenresCollectionViewModelInput(genreSelected: genreSelected)

        // Outputs

        let output = viewModel.transform(input: input)

        output.navigateToBooksByGenreScene
            .drive()
            .disposed(by: disposeBag)

        // Genres collectionView binding

        viewModel.genres
            .drive(collectionView.rx.items) { collectionView, row, _ in
                let indexPath = IndexPath(row: row, section: 0)
                let cell = collectionView.dequeueReusableCell(ofType: UICollectionViewCell.self, for: indexPath)
                cell.backgroundColor = .yellow
                return cell
            }
            .disposed(by: disposeBag)
    }
}
