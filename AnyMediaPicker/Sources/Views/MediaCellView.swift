//
//  MediaCellView.swift
//  AnyMediaPicker
//
//  Created by Yumenosuke Koukata on 2020/09/16.
//  Copyright © 2020 ZYXW. All rights reserved.
//

import UIKit
import RxCells
import RxSwift
import RxCocoa
import RxBinding
import Reusable

class MediaCellView: UITableViewCell {
	
	private typealias Input = MediaCellViewModelInput
	private typealias Output = MediaCellViewModelOutput
	
	@IBOutlet private weak var thumbnailImageView: UIImageView!
	@IBOutlet private weak var titleLabel: UILabel!
	
	private var input: Input!
	private var output: Output!
	private var disposeBag: DisposeBag!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		
	}
}

extension MediaCellView: NibLoadable, Reusable {}

extension MediaCellView: Configurable {
	
	func configure(with model: MediaCellModel) {
		let viewModel = MediaCellViewModel(model: model)
		input = viewModel
		output = viewModel
		
		// Unbind all
		disposeBag = .init()
		
		// Bind again
		disposeBag ~
			output.thumbnail ~> thumbnailImageView.rx.image ~
			output.title ~> titleLabel.rx.text
	}
}
