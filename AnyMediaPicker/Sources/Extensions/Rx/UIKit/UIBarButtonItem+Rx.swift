//
//  UIBarButtonItem+Rx.swift
//  AnyMediaPicker
//
//  Created by Yumenosuke Koukata on 2020/09/23.
//  Copyright © 2020 ZYXW. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIBarButtonItem {
	
	var image: Binder<UIImage?> {
		.init(self.base) {
			$0.image = $1
		}
	}
}
