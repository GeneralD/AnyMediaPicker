//
//  ArrayExtension.swift
//  AnyMediaPicker
//
//  Created by Yumenosuke Koukata on 2020/09/23.
//  Copyright © 2020 ZYXW. All rights reserved.
//

import Foundation

public extension Array {
	
	init(just: Element) {
		self = [just]
	}
	
	func removing(at index: Int) -> [Element] {
		var a = self
		a.remove(at: index)
		return a
	}
	
	func swapping(at i: Int, _ j: Int) -> [Element] {
		var a = self
		a.swapAt(i, j)
		return a
	}
}
