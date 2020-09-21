//
//  MediaListViewModel.swift
//  AnyMediaPicker
//
//  Created by Yumenosuke Koukata on 2020/09/15.
//  Copyright © 2020 ZYXW. All rights reserved.
//

import Foundation
import Photos
import RxSwift
import RxRelay
import RxSwiftExt
import Permission
import RxPermission
import SwiftPrelude

protocol MediaListViewModelInput {
	var deleteButtonTapped: AnyObserver<()> { get }
	var cameraButtonTapped: AnyObserver<()> { get }
	var photoButtonTapped: AnyObserver<()> { get }
	var fileButtonTapped: AnyObserver<()> { get }
	var itemSelected: AnyObserver<IndexPath> { get }
}

protocol MediaListViewModelOutput {
	var items: Observable<[MediaCellModel]> { get }
	var present: Observable<UIViewController> { get }
}

final class MediaListViewModel: MediaListViewModelInput, MediaListViewModelOutput {
	
	// MARK: Inputs
	let deleteButtonTapped: AnyObserver<()>
	let cameraButtonTapped: AnyObserver<()>
	let photoButtonTapped: AnyObserver<()>
	let fileButtonTapped: AnyObserver<()>
	let itemSelected: AnyObserver<IndexPath>
	
	// MARK: Outputs
	let items: Observable<[MediaCellModel]>
	let present: Observable<UIViewController>
	
	private let disposeBag = DisposeBag()
	
	init(model: MediaListModel) {
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
		
		let _items = BehaviorSubject<[MediaCellModel]>(value: [])
		self.items = _items.asObservable()
		
		let _present = PublishSubject<UIViewController>()
		self.present = _present.asObservable()
		
		_deleteButtonTapped
			.mapTo([])
			.bind(to: _items)
			.disposed(by: disposeBag)
		
		let addItem = PublishRelay<MediaCellModel>()
		addItem.map { [$0] }
			.withLatestFrom(_items, resultSelector: +)
			.bind(to: _items)
			.disposed(by: disposeBag)
		
		_cameraButtonTapped
			.flatMapTo(defer: Permission.camera.rx.permission)
			.filter(.authorized)
			.mapTo(defer: UIImagePickerController() |> \.sourceType … .camera)
			.do(onNext: _present.onNext)
			.flatMapAt(\.rx.didFinishPickingMediaWithInfo)
			.mapAt(\.[.phAsset])
			.ofType(PHAsset.self)
			.flatMapAt(\.rx.cellModel)
			.bind(to: addItem)
			.disposed(by: disposeBag)
		
		_photoButtonTapped
			.flatMapTo(defer: Permission.photos.rx.permission)
			.filter(.authorized)
			.mapTo(defer: UIImagePickerController() |> \.sourceType … .photoLibrary)
			.do(onNext: _present.onNext)
			.flatMapAt(\.rx.didFinishPickingMediaWithInfo)
			.mapAt(\.[.phAsset])
			.ofType(PHAsset.self)
			.flatMapAt(\.rx.cellModel)
			.bind(to: addItem)
			.disposed(by: disposeBag)
		
		//		_fileButtonTapped
		//			.mapTo([MediaCellModel()])
		//			.withLatestFrom(_items, resultSelector: +)
		//			.bind(to: _items)
		//			.disposed(by: disposeBag)
	}
}

