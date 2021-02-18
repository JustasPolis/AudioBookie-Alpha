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
                    case .BooksCollectionView(let viewModel):
                        let cell = collectionView.dequeueReusableCell(ofType: BooksCollectionView.self, for: indexPath)
                        cell.viewModel = viewModel
                        return cell
                    case .GenresCollectionView(let viewModel):
                        let cell = collectionView.dequeueReusableCell(ofType: GenresCollectionView.self, for: indexPath)
                        cell.viewModel = viewModel
                        return cell
                    case .LanguagesCollectionView(let viewModel):
                        let cell = collectionView.dequeueReusableCell(ofType: LanguagesCollectionView.self, for: indexPath)
                        cell.viewModel = viewModel
                        return cell
                }
            }, configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, kindType: SectionHeader.self, for: indexPath)
                header.sectionLabel.text = dataSource.sectionModels[indexPath.section].header
                return header
            })
    }
}

enum BrowseCollectionViewChildViewType {
    case BooksCollectionView(_ viewModel: BooksCollectionViewModel)
    case GenresCollectionView(_ viewModel: GenresCollectionViewModel)
    case LanguagesCollectionView(_ viewModel: GenresCollectionViewModel)
}

enum BrowseCollectionViewSectionModel {
    case NewBooksSection(childCollectionView: BrowseCollectionViewChildViewType)
    case TopBooksSection(childCollectionView: BrowseCollectionViewChildViewType)
    case LanguagesSection(childCollectionView: BrowseCollectionViewChildViewType)
    case GenresSection(childCollectionView: BrowseCollectionViewChildViewType)
}

extension BrowseCollectionViewSectionModel: SectionModelType {

    typealias Item = BrowseCollectionViewChildViewType
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

    var items: [BrowseCollectionViewChildViewType] {
        switch self {
            case .NewBooksSection(childCollectionView: let childCollectionView):
                return [childCollectionView]
            case .TopBooksSection(childCollectionView: let childCollectionView):
                return [childCollectionView]
            case .LanguagesSection(childCollectionView: let childCollectionView):
                return [childCollectionView]
            case .GenresSection(childCollectionView: let childCollectionView):
                return [childCollectionView]
        }
    }

    init(original: Self, items: [Self.Item]) {
        self = original
    }
}
