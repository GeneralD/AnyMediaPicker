//
//  PHAsset+App.swift
//  AnyMediaPicker
//
//  Created by Yumenosuke Koukata on 2020/09/21.
//  Copyright © 2020 ZYXW. All rights reserved.
//

import Photos
import RxSwift

extension Reactive where Base: PHAsset {
	
	var cellModel: Observable<MediaCellModel> {
		return .create { [weak base] observer -> Disposable in
			let disposable = CompositeDisposable()
			
			guard let b = base, b.mediaType == .image else {
				observer.onCompleted()
				return disposable
			}
			
			PHImageManager.default().requestImage(for: b, targetSize: .init(width: b.pixelWidth, height: b.pixelHeight), contentMode: .aspectFit, options: nil) { image, info in
				defer { observer.onCompleted() }
				let url = info?["PHImageFileURLKey"] as? URL
				guard let name = url?.deletingPathExtension().lastPathComponent, let image = image else { return }
				observer.onNext(.init(title: name, image: image))
			}
			return disposable
		}
	}
}
