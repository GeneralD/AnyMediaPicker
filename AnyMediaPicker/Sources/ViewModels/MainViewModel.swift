//
//  MainViewModel.swift
//  AnyMediaPicker
//
//  Created by Yumenosuke Koukata on 2020/09/15.
//  Copyright © 2020 ZYXW. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

protocol MainViewModelInput {
	var deleteButtonTapped: AnyObserver<()> { get }
	var cameraButtonTapped: AnyObserver<()> { get }
	var photoButtonTapped: AnyObserver<()> { get }
	var fileButtonTapped: AnyObserver<()> { get }
	var itemSelected: AnyObserver<IndexPath> { get }
}

protocol MainViewModelOutput {
	//	var title: Observable<String?> { get }
}

final class MediaListViewModel: MainViewModelInput, MainViewModelOutput {
	
	// MARK: Inputs
	let deleteButtonTapped: AnyObserver<()>
	let cameraButtonTapped: AnyObserver<()>
	let photoButtonTapped: AnyObserver<()>
	let fileButtonTapped: AnyObserver<()>
	let itemSelected: AnyObserver<IndexPath>
	
	// MARK: Outputs
	//	let title: Observable<String?>
	
	private let disposeBag = DisposeBag()
	
	init(model: MainModel) {
		let _deleteButtonTapped = PublishSubject<()>()
		self.deleteButtonTapped = _deleteButtonTapped.asObserver()
		
		let _cameraButtonTapped = PublishSubject<()>()
		self.cameraButtonTapped = _cameraButtonTapped.asObserver()
		
		let _photoButtonTapped = PublishSubject<()>()
		self.photoButtonTapped = _photoButtonTapped.asObserver()
		
		let _fileButtonTapped = PublishSubject<()>()
		self.fileButtonTapped = _fileButtonTapped.asObserver()
		
		let _itemSelected = PublishSubject<IndexPath>()
		self.itemSelected = _itemSelected.asObserver()
	}
}
