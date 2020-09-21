//
//  ObservableTypeExtension.swift
//  AnyMediaPicker
//
//  Created by Yumenosuke Koukata on 2020/09/21.
//  Copyright © 2020 ZYXW. All rights reserved.
//

import RxSwift

public extension ObservableType {
	
	func merge(_ sources: Observable<Element>...) -> Observable<Element> {
		.merge([self.asObservable()] + sources)
	}
	
	func combineLatest<Another: ObservableType, ResultElement>(_ source1: Another, resultSelector: @escaping (Element, Another.Element) throws -> ResultElement) -> Observable<ResultElement> {
		.combineLatest(self, source1, resultSelector: resultSelector)
	}
}

// MARK: Map

extension ObservableType {

	public func mapTo<Result>(defer value: @escaping @autoclosure () -> Result) -> Observable<Result> {
		return map { _ in value() }
	}
}

// MARK: CompactMap

public extension ObservableType {
	
	func compactMapAt<Result>(_ keyPath: KeyPath<Element, Result?>) -> Observable<Result> {
		compactMap { $0[keyPath: keyPath] }
	}
}

public extension ObservableType where Element: OptionalType {
	
	func compacted() -> Observable<Element.WrappedType> {
		compactMap { $0 as? Self.Element.WrappedType }
	}
}

public protocol OptionalType {
	associatedtype WrappedType
}

extension Optional: OptionalType {
	public typealias WrappedType = Wrapped
}

// MARK: FlatMap

public extension ObservableType {
	
	func flatMapAt<Result>(_ keyPath: KeyPath<Element, Observable<Result>>) -> Observable<Result> {
		flatMap { $0[keyPath: keyPath] }
	}
	
	func flatMapTo<Result>(_ observable: Observable<Result>) -> Observable<Result> {
		flatMap { _ in observable }
	}
	
	func flatMapTo<Result>(defer observable: @escaping @autoclosure () -> Observable<Result>) -> Observable<Result> {
		flatMap { _ in observable() }
	}
}

public extension ObservableType where Element: ObservableConvertibleType {
	
	func flatten() -> Observable<Element.Element> {
		flatMap { $0 }
	}
}

// MARK: Filter

public extension ObservableType where Element: Equatable {
	
	func filter(_ element: Element) -> Observable<Element> {
		filter { $0 == element }
	}
}
