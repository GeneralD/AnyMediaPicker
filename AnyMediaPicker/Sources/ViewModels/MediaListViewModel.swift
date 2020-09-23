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
	var editButtonTapped: AnyObserver<()> { get }
	var itemMoved: AnyObserver<ItemMovedEvent> { get }
	var itemDeleted: AnyObserver<IndexPath> { get }
}

protocol MediaListViewModelOutput {
	var items: Observable<[MediaCellModel]> { get }
	var present: Observable<UIViewController> { get }
	var isTableEditing: Observable<Bool> { get }
	var editButtonImage: Observable<UIImage> { get }
}

final class MediaListViewModel: MediaListViewModelInput, MediaListViewModelOutput {
	
	// MARK: Inputs
	let deleteButtonTapped: AnyObserver<()>
	let cameraButtonTapped: AnyObserver<()>
	let photoButtonTapped: AnyObserver<()>
	let fileButtonTapped: AnyObserver<()>
	let editButtonTapped: AnyObserver<()>
	let itemMoved: AnyObserver<ItemMovedEvent>
	let itemDeleted: AnyObserver<IndexPath>
	
	// MARK: Outputs
	let items: Observable<[MediaCellModel]>
	let present: Observable<UIViewController>
	let isTableEditing: Observable<Bool>
	let editButtonImage: Observable<UIImage>
	
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
		
		let _editButtonTapped = PublishSubject<()>()
		self.editButtonTapped = _editButtonTapped.asObserver()
		
		let _itemMoved = PublishSubject<ItemMovedEvent>()
		self.itemMoved = _itemMoved.asObserver()
		
		let _itemDeleted = PublishSubject<IndexPath>()
		self.itemDeleted = _itemDeleted.asObserver()
		
		let _items = BehaviorRelay<[MediaCellModel]>(value: [])
		self.items = _items.asObservable()
		
		let _present = PublishRelay<UIViewController>()
		self.present = _present.asObservable()
		
		let _isTableEditing = BehaviorRelay(value: false)
		self.isTableEditing = _isTableEditing.asObservable()
		
		let _editButtonImage = PublishRelay<UIImage>()
		self.editButtonImage = _editButtonImage.asObservable()
		
		_deleteButtonTapped
			.mapTo([])
			.bind(to: _items)
			.disposed(by: disposeBag)
		
		let addItem = PublishRelay<MediaCellModel>()
		addItem
			.map(Array.init(just: ))
			.withLatestFrom(_items, resultSelector: +)
			.bind(to: _items)
			.disposed(by: disposeBag)
		
		_cameraButtonTapped
			.flatMapTo(defer: Permission.camera.rx.permission)
			.filter(.authorized)
			.mapTo(defer: UIImagePickerController() |> \.sourceType … .camera)
			.do(onNext: _present.accept)
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
			.do(onNext: _present.accept)
			.flatMapAt(\.rx.didFinishPickingMediaWithInfo)
			.mapAt(\.[.phAsset])
			.ofType(PHAsset.self)
			.flatMapAt(\.rx.cellModel)
			.bind(to: addItem)
			.disposed(by: disposeBag)
		
		_fileButtonTapped
			.mapTo(defer: UIDocumentPickerViewController(documentTypes: ["public.image"], in: .import))
			.do(onNext: _present.accept)
			.flatMapAt(\.rx.didPickDocumentsAt)
			.compactMapAt(\.first?.cellModel)
			.bind(to: addItem)
			.disposed(by: disposeBag)
		
		_editButtonTapped
			.withLatestFrom(_isTableEditing)
			.not()
			.bind(to: _isTableEditing)
			.disposed(by: disposeBag)
		
		_isTableEditing
			.map(true: "pencil.slash", false: "pencil")
			.compactMap(UIImage.init(systemName: ))
			.bind(to: _editButtonImage)
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

private extension URL {
	
	var cellModel: MediaCellModel? {
		guard let data = try? Data(contentsOf: self),
			  let image = UIImage(data: data) else { return nil }
		let title = deletingPathExtension().lastPathComponent
		return MediaCellModel(title: title, image: image)
	}
}
