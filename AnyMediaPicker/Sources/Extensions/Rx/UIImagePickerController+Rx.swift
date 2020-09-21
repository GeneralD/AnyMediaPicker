//
//  UIImagePickerController+Rx.swift
//  AnyMediaPicker
//
//  Created by Yumenosuke Koukata on 2020/09/21.
//  Copyright © 2020 ZYXW. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit

extension Reactive where Base: UIImagePickerController {
	
	/**
	Reactive wrapper for `delegate` message.
	*/
	public var didFinishPickingMediaWithInfo: Observable<[UIImagePickerController.InfoKey : Any]> {
		return delegate
			.methodInvoked(#selector(UIImagePickerControllerDelegate.imagePickerController(_:didFinishPickingMediaWithInfo:)))
			.map {
				try castOrThrow([UIImagePickerController.InfoKey : Any].self, $0[1])
		}
	}
	
	/**
	Reactive wrapper for `delegate` message.
	*/
	public var didCancel: Observable<()> {
		return delegate
			.methodInvoked(#selector(UIImagePickerControllerDelegate.imagePickerControllerDidCancel(_:)))
			.map {_ in () }
	}
	
}

fileprivate func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
	guard let returnValue = object as? T else {
		throw RxCocoaError.castingError(object: object, targetType: resultType)
	}
	return returnValue
}

public class RxImagePickerDelegateProxy: RxNavigationControllerDelegateProxy, UIImagePickerControllerDelegate {
	
	public init(imagePicker: UIImagePickerController) {
		super.init(navigationController: imagePicker)
	}
}

private let setupRxImagePicker: () = {
	RxImagePickerDelegateProxy.register(make: RxImagePickerDelegateProxy.init(imagePicker: ))
} ()
