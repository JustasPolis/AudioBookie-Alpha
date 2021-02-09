//
//  Reusable.swift
//  AudioBookie
//
//  Created by Justin on 2021-01-24.
//

import UIKit

protocol Reusable {
    static var reuseID: String { get }
}

extension Reusable {
    static var reuseID: String {
        String(describing: self)
    }
}

extension UITableViewCell: Reusable {}
extension UICollectionReusableView: Reusable {}


extension UITableView {
    func register<T: UITableViewCell>(cellType: T.Type = T.self) {
        register(cellType.self, forCellReuseIdentifier: cellType.reuseID)
    }

    func dequeueReusableCell<T>(ofType cellType: T.Type = T.self, at indexPath: IndexPath) -> T where T: UITableViewCell {
        guard let cell = dequeueReusableCell(withIdentifier: cellType.reuseID,
                                             for: indexPath) as? T
        else {
            fatalError()
        }
        return cell
    }
}

extension UICollectionView {

    func register<T: UICollectionViewCell>(cellType: T.Type = T.self) {
        register(cellType.self, forCellWithReuseIdentifier: cellType.reuseID)
    }

    func registerHeader<T: UICollectionReusableView>(type: T.Type = T.self) {
        register(type.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: type.reuseID)
    }

    func registerFooter<T: UICollectionReusableView>(type: T.Type = T.self) {
        register(type.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: type.reuseID)
    }

    func dequeueReusableCell<T: UICollectionViewCell>(ofType cellType: T.Type = T.self, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: cellType.reuseID,
                                             for: indexPath) as? T
        else {
            fatalError()
        }
        return cell
    }

    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind kind: String, kindType: T.Type = T.self, for indexPath: IndexPath) -> T {
        guard let supplementaryView = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kindType.reuseID, for: indexPath) as? T
        else {
            fatalError()
        }
        return supplementaryView
    }
}
