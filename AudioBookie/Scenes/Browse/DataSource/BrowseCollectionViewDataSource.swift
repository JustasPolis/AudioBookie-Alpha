//
//  BrowseCollectionViewDataSource.swift
//  AudioBookie
//
//  Created by Justin on 2021-01-22.
//

import RxDataSources

struct BrowseCollectionViewDataSource {
    typealias DataSource = RxCollectionViewSectionedReloadDataSource
    static func dataSource() -> DataSource<BrowseCollectionViewSectionModel> {
        .init(
            configureCell: { dataSource, collectionView, indexPath, _ in
                switch dataSource[indexPath] {
                    case .HorizontalList(let viewModel):
                        let cell = collectionView.dequeueReusableCell(ofType: BooksCollectionView.self, for: indexPath)
                        cell.viewModel = viewModel
                        return cell
                    case .VerticalListItem(let text):
                        let cell = collectionView.dequeueReusableCell(ofType: VerticalListCell.self, for: indexPath)
                        cell.titleLabel.text = text
                        return cell
                }
            }, configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, kindType: SectionHeader.self, for: indexPath)
                header.sectionLabel.text = dataSource.sectionModels[indexPath.section].header
                return header
            })
    }
}

enum BrowseCollectionViewSectionItem {
    case HorizontalList(_ viewModel: BooksCollectionViewModel)
    case VerticalListItem(text: String)
}

enum BrowseCollectionViewSectionModel {
    case NewBooksSection(childCollectionView: BrowseCollectionViewSectionItem)
    case TopBooksSection(childCollectionView: BrowseCollectionViewSectionItem)
    case LanguagesSection(items: [BrowseCollectionViewSectionItem])
    case GenresSection(items: [BrowseCollectionViewSectionItem])
}

extension BrowseCollectionViewSectionModel: SectionModelType {

    typealias Item = BrowseCollectionViewSectionItem
    var header: String {
        switch self {
            case .NewBooksSection:
                return "New Releases"
            case .TopBooksSection:
                return "Top Books"
            case .LanguagesSection:
                return "Languages"
            case .GenresSection:
                return "Genres"
        }
    }

    var items: [BrowseCollectionViewSectionItem] {
        switch self {
            case .NewBooksSection(childCollectionView: let childCollectionView):
                return [childCollectionView]
            case .TopBooksSection(childCollectionView: let childCollectionView):
                return [childCollectionView]
            case .LanguagesSection(items: let items):
                return items
            case .GenresSection(items: let items):
                return items
        }
    }

    init(original: Self, items: [Self.Item]) {
        self = original
    }
}
