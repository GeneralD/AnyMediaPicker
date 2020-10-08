//
//  UIViewController+Rx.swift
//  AnyMediaPicker
//
//  Created by Yumenosuke Koukata on 2020/09/21.
//  Copyright © 2020 ZYXW. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public extension Reactive where Base: UIViewController {
	var present: Binder<UIViewController> {
		.init(self.base) { vc, view in
			vc.present(view, animated: true)
		}
	}
	
	var pushViewController: Binder<UIViewController> {
		.init(self.base) { vc, view in
			vc.navigationController?.pushViewController(view, animated: true)
		}
	}
}
