//
//  MediaListViewController.swift
//  AnyMediaPicker
//
//  Created by Yumenosuke Koukata on 2020/09/15.
//  Copyright © 2020 ZYXW. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxBinding
import RxCells
import RxDataSources
import Instantiate
import InstantiateStandard

class MediaListViewController: UIViewController, StoryboardInstantiatable {
	
	private typealias Input = MediaListViewModelInput
	private typealias Output = MediaListViewModelOutput
	
	@IBOutlet private weak var tableView: UITableView!
	@IBOutlet private weak var deleteButton: UIBarButtonItem!
	@IBOutlet private weak var cameraButton: UIBarButtonItem!
	@IBOutlet private weak var photoButton: UIBarButtonItem!
	@IBOutlet private weak var fileButton: UIBarButtonItem!
	@IBOutlet private weak var editButton: UIBarButtonItem!
	
	private var input: Input!
	private var output: Output!
	private let disposeBag = DisposeBag()
	
	func inject(_ dependency: MediaListModel) {
		let viewModel = MediaListViewModel(model: dependency)
		self.input = viewModel
		self.output = viewModel
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let cellType = MediaCellView.self
		tableView.register(cellType: cellType)
		tableView.isEditing = true
		
		disposeBag ~
			deleteButton.rx.tap ~> input.deleteButtonTapped ~
			cameraButton.rx.tap ~> input.cameraButtonTapped ~
			photoButton.rx.tap ~> input.photoButtonTapped ~
			fileButton.rx.tap ~> input.fileButtonTapped ~
			editButton.rx.tap ~> input.editButtonTapped ~
			tableView.rx.itemMoved ~> input.itemMoved ~
			tableView.rx.itemDeleted ~> input.itemDeleted
		
		disposeBag ~
			output.items ~> tableView.rx.animatedCells(cellType) ~
			output.isTableEditing ~> tableView.rx.isEditing(animated: true) ~
			output.isTableEditing ~> cameraButton.rx.isEnabled.mapObserver(!) ~
			output.isTableEditing ~> photoButton.rx.isEnabled.mapObserver(!) ~
			output.isTableEditing ~> fileButton.rx.isEnabled.mapObserver(!) ~
			output.isTableEditing ~> deleteButton.rx.isEnabled ~
			output.editButtonImage ~> editButton.rx.image ~
			output.present ~> rx.present
	}
}
