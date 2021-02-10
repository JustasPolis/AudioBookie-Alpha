//
//  BooksDetailsViewController.swift
//  AudioBookie
//
//  Created by Justin on 2021-01-25.
//

import RxCocoa
import RxDataSources
import RxSwift
import UIKit

class BookDetailsViewController: UIViewController {

    private let viewModel: BookDetailsViewModelType
    private let book: Book
    private let disposeBag = DisposeBag()
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    private let v = UIView()

    required init(viewModel: BookDetailsViewModelType, book: Book) {
        self.book = book
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
        v.backgroundColor = .purple
        v.add(to: view)
        v.alpha = 0
        v.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        v.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true
        v.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
    }

    private func bindViewModel() {

        let dataSource = BookDetailsDataSource.dataSource()

        let chapterSelected = collectionView.rx.itemSelected.asDriver()

        // input

        let input = BookDetailsViewModelInput(book: .just(book), chapterSelected: chapterSelected)

        let output = viewModel.transform(input: input)

        output.presentAudioPlayerScene
            .drive()
            .disposed(by: disposeBag)

        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        output.loading.drive(onNext: { [weak self] loading in
            guard let strongSelf = self else { return }
            let height = loading ? strongSelf.view.safeAreaLayoutGuide.layoutFrame.height * 0.6 - 60 : 0
            flowLayout.footerReferenceSize = CGSize(width: strongSelf.view.frame.width, height: height)
        }).disposed(by: disposeBag)

        output.chapters.map { chapters -> [BookDetailsSectionModel] in
            [.ChaptersSection(loading: false, items: chapters.map { chapter in
                .ChapterItem(chapter: chapter)
            })]
        }.startWith([.ChaptersSection(loading: true, items: [])])
            .drive(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

    private func setupCollectionView() {

        // CollectionView setup

        collectionView.do {
            $0.register(cellType: ChapterCell.self)
            $0.registerHeader(type: BookDetailsHeader.self)
            $0.registerFooter(type: BookDetailsFooter.self)
            $0.backgroundColor = .white
            $0.add(to: self.view)
            $0.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            $0.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            $0.alwaysBounceVertical = false
            $0.showsVerticalScrollIndicator = false
            $0.delegate = self
        }

        // FlowLayout setup

        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        flowLayout.do {
            $0.itemSize = CGSize(width: view.frame.width, height: 60)
            $0.headerReferenceSize = CGSize(width: view.frame.width, height: view.safeAreaLayoutGuide.layoutFrame.height * 0.4)
        }
    }
}

extension BookDetailsViewController: UICollectionViewDelegateFlowLayout {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var percentageScrolled: CGFloat
        percentageScrolled = scrollView.contentOffset.y / view.frame.width - 0
        if percentageScrolled < 0.6 {
            return
        }

        UIView.animate(withDuration: 0.5) {
            self.v.alpha = fmax(0.0, percentageScrolled)
        }
    }
}