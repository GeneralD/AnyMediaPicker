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
		
		tableView.delegate = nil
		tableView.dataSource = nil
		tableView.register(cellType: MediaCellView.self)
		
		disposeBag ~
			deleteButton.rx.tap ~> input.deleteButtonTapped ~
			cameraButton.rx.tap ~> input.cameraButtonTapped ~
			photoButton.rx.tap ~> input.photoButtonTapped ~
			fileButton.rx.tap ~> input.fileButtonTapped ~
			tableView.rx.itemSelected ~> input.itemSelected
		
		disposeBag ~
			output.items ~> tableView.rx.cells(MediaCellView.self)
	}
}
