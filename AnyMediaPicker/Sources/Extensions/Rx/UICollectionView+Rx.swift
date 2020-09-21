//
//  UICollectionView+Rx.swift
//  AnyMediaPicker
//
//  Created by Yumenosuke Koukata on 2020/09/21.
//  Copyright © 2020 ZYXW. All rights reserved.
//

import UIKit
import RxSwift
import RxCells
import RxDataSources
import Reusable

public extension Reactive where Base: UICollectionView {
	
	func reloadCells<S: Sequence, Cell: UICollectionViewCell, O: ObservableType>(_: Cell.Type) -> (_ _: O) -> Disposable where O.Element == S, Cell: Reusable & Configurable, Cell.Model == S.Iterator.Element {
	{ source in
		source
			.map(Array.init) // sequence to array
			.map { SectionModel<(), Cell.Model>(model: (), items: $0) } // cell models to a section model
			.map { [$0] } // as single section array
			.bind(to: self.items(dataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<(), Cell.Model>>(configureCell: { _, collectionView, indexPath, item in
				let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as! Cell
				cell.configure(with: item)
				return cell
			})))
		}
	}
}
