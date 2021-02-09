//
//  BrowseCollectionViewCell.swift
//  AudioBookie
//
//  Created by Justin on 2021-01-22.
//

import RxCocoa
import RxSwift
import UIKit

class BrowseCollectionViewCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        6
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath)
        cell.backgroundColor = .purple
        return cell
    }

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    override init(frame: CGRect) {
        super.init(frame: .zero)
        backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cellId")
        addSubview(collectionView)
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        collectionView.showsHorizontalScrollIndicator = false
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: frame.height, height: frame.height)
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 14.0, bottom: 0, right: 14.0)

        collectionView.rx.modelSelected(String.self).asDriver().drive(onNext: { value in
            print(value)
        })
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(_ array: [String]) {
        print(array)
    }
}
