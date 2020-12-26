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
	var present: Observable<UIViewController?> { get }
	var isTableEditing: Observable<Bool> { get }
	var editButtonImage: Observable<UIImage?> { get }
	var areMediaButtonsEnabled: Observable<Bool> { get }
}

final class MediaListViewModel: MediaListViewModelInput, MediaListViewModelOutput {
	
	// MARK: Inputs
	@RxTrigger var deleteButtonTapped: AnyObserver<()>
	@RxTrigger var cameraButtonTapped: AnyObserver<()>
	@RxTrigger var photoButtonTapped: AnyObserver<()>
	@RxTrigger var fileButtonTapped: AnyObserver<()>
	@RxTrigger var editButtonTapped: AnyObserver<()>
	@RxTrigger var itemMoved: AnyObserver<ItemMovedEvent>
	@RxTrigger var itemDeleted: AnyObserver<IndexPath>
	
	// MARK: Outputs
	@RxProperty(value: []) var items: Observable<[MediaCellModel]>
	@RxProperty(value: nil) var present: Observable<UIViewController?>
	@RxProperty(value: false) var isTableEditing: Observable<Bool>
	@RxProperty(value: nil) var editButtonImage: Observable<UIImage?>
	@RxProperty(value: true) var areMediaButtonsEnabled: Observable<Bool>
	
	private let disposeBag = DisposeBag()
	
	init(model: MediaListModel) {
		$deleteButtonTapped
			.mapTo([])
			.bind(to: $items)
			.disposed(by: disposeBag)
		
		let addItem = PublishRelay<MediaCellModel>()
		addItem
			.map(Array.init(just: ))
			.withLatestFrom($items, resultSelector: +)
			.bind(to: $items)
			.disposed(by: disposeBag)
		
		let newImagePicker: Observable<UIImagePickerController> = $cameraButtonTapped
			.flatMapTo(defer: Permission.camera.rx.permission)
			.filter(.authorized)
			.mapTo(defer: .init() |> \.sourceType … .camera)
			.merge($photoButtonTapped
					.flatMapTo(defer: Permission.photos.rx.permission)
					.filter(.authorized)
					.mapTo(defer: .init() |> \.sourceType … .photoLibrary))
			.share()
		
		newImagePicker
			.ofType(UIViewController.self)
			.bind(to: $present)
			.disposed(by: disposeBag)
		
		newImagePicker
			.flatMap(\.rx.didFinishPickingMediaWithInfo)
			.map(\.[.phAsset])
			.ofType(PHAsset.self)
			.flatMap(\.rx.cellModel)
			.bind(to: addItem)
			.disposed(by: disposeBag)
		
		$fileButtonTapped
			.mapTo(defer: UIDocumentPickerViewController(documentTypes: ["public.image"], in: .import))
			.do(onNext: $present.accept)
			.flatMap(\.rx.didPickDocumentsAt)
			.compactMap(\.first?.cellModel)
			.bind(to: addItem)
			.disposed(by: disposeBag)
		
		$editButtonTapped
			.withLatestFrom($isTableEditing)
			.not()
			.bind(to: $isTableEditing)
			.disposed(by: disposeBag)
		
		$isTableEditing
			.map(true: "pencil.slash", false: "pencil")
			.compactMap(UIImage.init(systemName: ))
			.bind(to: $editButtonImage)
			.disposed(by: disposeBag)
		
		$isTableEditing
			.not()
			.bind(to: $areMediaButtonsEnabled)
			.disposed(by: disposeBag)
		
		$itemDeleted
			.withLatestFrom($items) { $1.removing(at: $0.row) }
			.bind(to: $items)
			.disposed(by: disposeBag)
		
		$itemMoved
			.withLatestFrom($items) { $1.swapping(at: $0.sourceIndex.row, $0.destinationIndex.row) }
			.bind(to: $items)
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
