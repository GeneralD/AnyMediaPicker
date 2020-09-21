//
//  PHAsset+App.swift
//  AnyMediaPicker
//
//  Created by Yumenosuke Koukata on 2020/09/21.
//  Copyright © 2020 ZYXW. All rights reserved.
//

import Photos
import RxSwift
import SwiftPrelude

extension Reactive where Base: PHAsset {
	
	var cellModel: Observable<MediaCellModel> {
		return .create { [weak base] observer -> Disposable in
			let disposable = CompositeDisposable()
			
			guard let asset = base, asset.mediaType == .image else {
				observer.onCompleted()
				return disposable
			}
			
			let options: PHImageRequestOptions = PHImageRequestOptions()
				|> \.deliveryMode … .highQualityFormat
				|> \.isNetworkAccessAllowed … true
				|> \.isSynchronous … false
				|> \.version … .current
				|> \.deliveryMode … .opportunistic
				|> \.resizeMode … .fast
				|> \.progressHandler … { _, _, _, _ in print("Loading image from iCloud") }
			
			let size = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
			
			PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: options) { image, info in
				defer { observer.onCompleted() }
				let url = info?["PHImageFileURLKey"] as? URL
				guard let name = url?.deletingPathExtension().lastPathComponent, let image = image else { return }
				observer.onNext(.init(title: name, image: image))
			}
			
			return disposable
		}
	}
}
