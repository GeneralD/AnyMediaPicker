//
//  AppDelegate.swift
//  AnyMediaPicker
//
//  Created by Yumenosuke Koukata on 2020/09/15.
//  Copyright © 2020 ZYXW. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// First view and model
		let model = MediaListModel()
		let view = MediaListViewController(with: model)
		// Present by window
		window = .init(frame: UIScreen.main.bounds)
		window?.rootViewController = view
		window?.makeKeyAndVisible()
		
		return true
	}
}
