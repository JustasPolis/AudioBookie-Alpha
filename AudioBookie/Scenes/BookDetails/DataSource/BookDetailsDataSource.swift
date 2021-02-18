//
//  BookDetailsDataSource.swift
//  AudioBookie
//
//  Created by Justin on 2021-01-26.
//

import RxDataSources

struct BookDetailsDataSource {
    typealias DataSource = RxCollectionViewSectionedReloadDataSource
    static func dataSource() -> DataSource<BookDetailsSectionModel> {
        .init(
            configureCell: { dataSource, collectionView, indexPath, _ in
                switch dataSource[indexPath] {
                    case .ChapterItem(let chapter):
                        let cell = collectionView.dequeueReusableCell(ofType: ChapterCell.self, for: indexPath)
                        cell.configure(with: chapter)
                        return cell
                }
            }, configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
                switch kind {
                    case UICollectionView.elementKindSectionHeader:
                        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, kindType: BookDetailsHeader.self, for: indexPath)
                        return header

                    case UICollectionView.elementKindSectionFooter:
                        let loading = dataSource.sectionModels[indexPath.section].loading
                        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, kindType: BookDetailsFooter.self, for: indexPath)
                        footer.loading = loading
                        return footer
                    default:
                        assert(false, "Unexpected element kind")
                }
            })
    }
}

enum BookDetailsSectionItem {
    case ChapterItem(chapter: Chapter)
}

enum BookDetailsSectionModel {
    case ChaptersSection(loading: Bool, items: [BookDetailsSectionItem])
}

extension BookDetailsSectionModel: SectionModelType {

    var items: [BookDetailsSectionItem] {
        switch self {
            case .ChaptersSection(_, let items):
                return items
        }
    }

    var loading: Bool {
        switch self {
            case .ChaptersSection(let loading, _):
                return loading
        }
    }

    init(original: Self, items: [Self.Item]) {
        self = original
    }
}
