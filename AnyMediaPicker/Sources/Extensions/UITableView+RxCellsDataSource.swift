//
//  UITableView+RxCellsDataSource.swift
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

public extension Reactive where Base: UITableView {
	
	func reloadCells<S: Sequence, Cell: UITableViewCell, O: ObservableType>(_: Cell.Type)
		-> (_ _: O)
		-> Disposable
		where O.Element == S, Cell: Reusable & Configurable, Cell.Model == S.Iterator.Element {
			return { source in
				return source
					.map { $0.map { $0 } }
					.map { SectionModel<(), Cell.Model>(model: (), items: $0) }
					.map { [$0] }
					.bind(to: self.items(dataSource: RxTableViewSectionedReloadDataSource<SectionModel<(), Cell.Model>>(configureCell: { _, tableView, indexPath, item in
						let cell = tableView.dequeueReusableCell(withIdentifier: Cell.reuseIdentifier, for: indexPath) as! Cell
						cell.configure(with: item)
						return cell
					})))
			}
	}
}

