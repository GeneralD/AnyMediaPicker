//
//  MediaCellViewModel.swift
//  AnyMediaPicker
//
//  Created by Yumenosuke Koukata on 2020/09/16.
//  Copyright © 2020 ZYXW. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxRelay

protocol MediaCellViewModelInput {
	
}

protocol MediaCellViewModelOutput {
	var thumbnail: Observable<UIImage?> { get }
	var title: Observable<String?> { get }
}

final class MediaCellViewModel: MediaCellViewModelInput, MediaCellViewModelOutput {
	
	// MARK: Inputs
	
	// MARK: Outputs
	let thumbnail: Observable<UIImage?>
	let title: Observable<String?>
	
	private let disposeBag = DisposeBag()
	
	init(model: MediaCellModel) {
		thumbnail = .just(model.image)
		title = .just(model.title)
	}
}

