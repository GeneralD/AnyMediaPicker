//
//  MediaListViewModel.swift
//  AnyMediaPicker
//
//  Created by Yumenosuke Koukata on 2020/09/15.
//  Copyright © 2020 ZYXW. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import RxSwiftExt

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
		
		_cameraButtonTapped
			.map { UIImagePickerController() }
			.do(onNext: _present.onNext)
			.flatMap { $0.rx.didFinishPickingMediaWithInfo }
			.compactMap { $0[.phAsset] as? PHAsset }
			.flatMap { $0.cellModel }
			.map { [$0] }
			.withLatestFrom(_items, resultSelector: +)
			.bind(to: _items)
			.disposed(by: disposeBag)
		
		_photoButtonTapped
			.map { UIImagePickerController() }
			.do(onNext: _present.onNext)
			.flatMap { $0.rx.didFinishPickingMediaWithInfo }
			.compactMap { $0[.phAsset] as? PHAsset }
			.flatMap { $0.cellModel }
			.map { [$0] }
			.withLatestFrom(_items, resultSelector: +)
			.bind(to: _items)
			.disposed(by: disposeBag)
		
//		_fileButtonTapped
//			.mapTo([MediaCellModel()])
//			.withLatestFrom(_items, resultSelector: +)
//			.bind(to: _items)
//			.disposed(by: disposeBag)
	}
}

import Photos

fileprivate extension PHAsset {
	
	var cellModel: Observable<MediaCellModel> {
		return .create { observer -> Disposable in
			let disposable = CompositeDisposable()
			
			guard self.mediaType == .image else {
				observer.onCompleted()
				return disposable
			}
			
			PHImageManager.default().requestImage(for: self, targetSize: .init(width: self.pixelWidth, height: self.pixelHeight), contentMode: .aspectFit, options: nil) { image, info in
				defer { observer.onCompleted() }
				let url = info?["PHImageFileURLKey"] as? URL
				guard let name = url?.deletingPathExtension().lastPathComponent, let image = image else { return }
				observer.onNext(.init(title: name, image: image))
			}
			return disposable
		}
	}
}
