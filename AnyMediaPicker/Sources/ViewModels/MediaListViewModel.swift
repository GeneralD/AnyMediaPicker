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
import RxCocoa
import RxRelay
import RxSwiftExt
import RxDocumentPicker
import RxPermission
import Permission
import SwiftPrelude

protocol MediaListViewModelInput {
	var deleteButtonTapped: AnyObserver<()> { get }
	var cameraButtonTapped: AnyObserver<()> { get }
	var photoButtonTapped: AnyObserver<()> { get }
	var fileButtonTapped: AnyObserver<()> { get }
	var itemMoved: AnyObserver<ItemMovedEvent> { get }
	var itemDeleted: AnyObserver<IndexPath> { get }
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
	let itemMoved: AnyObserver<ItemMovedEvent>
	let itemDeleted: AnyObserver<IndexPath>
	
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
		
		let _itemMoved = PublishSubject<ItemMovedEvent>()
		self.itemMoved = _itemMoved.asObserver()
		
		let _itemDeleted = PublishSubject<IndexPath>()
		self.itemDeleted = _itemDeleted.asObserver()
		
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
		
		_fileButtonTapped
			.mapTo(defer: UIDocumentPickerViewController(documentTypes: ["public.image"], in: .import))
			.do(onNext: _present.onNext)
			.flatMapAt(\.rx.didPickDocumentsAt)
			.compactMapAt(\.first)
			.filterMap({ url in
				let data = try Data(contentsOf: url)
				guard let image = UIImage(data: data) else { return .ignore }
				let title = url.deletingPathExtension().lastPathComponent
				return .map(MediaCellModel(title: title, image: image))
			})
			.bind(to: addItem)
			.disposed(by: disposeBag)
		
		_itemDeleted
			.withLatestFrom(_items) { $1.removing(at: $0.row) }
			.bind(to: _items)
			.disposed(by: disposeBag)
		
		_itemMoved
			.withLatestFrom(_items) { $1.swapping(at: $0.sourceIndex.row, $0.destinationIndex.row) }
			.bind(to: _items)
			.disposed(by: disposeBag)
	}
}

extension Array {
	
	func removing(at index: Int) -> [Element] {
		var a = self
		a.remove(at: index)
		return a
	}
	
	func swapping(at i: Int, _ j: Int) -> [Element] {
		var a = self
		a.swapAt(i, j)
		return a
	}
}
