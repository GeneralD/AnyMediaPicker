//
//  MediaCellViewModel.swift
//  AnyMediaPicker
//
//  Created by Yumenosuke Koukata on 2020/09/16.
//  Copyright © 2020 ZYXW. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

protocol MediaCellViewModelInput {
	
}

protocol MediaCellViewModelOutput {
	
}

final class MediaCellViewModel: MediaCellViewModelInput, MediaCellViewModelOutput {
	
	// MARK: Inputs
	
	// MARK: Outputs
	
	private let disposeBag = DisposeBag()
	
	init(model: MediaCellModel) {
		
	}
}

