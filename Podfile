platform :ios, '13.0'

target 'AnyMediaPicker' do
	use_frameworks!
	
	pod 'RxSwift'
	pod 'RxCocoa'
	pod 'RxOptional'
	pod 'RxBinding'
	pod 'RxSwiftExt'
	pod 'RxCells'
	pod 'RxDataSources'
	pod 'RxDocumentPicker'
	pod 'RxPermission/Camera'
	pod 'RxPermission/Photos'
	
	pod 'InstantiateStandard'
	pod 'SwiftPrelude'
	
end

post_install do |installer|
	installer.pods_project.targets.each do |target|
		target.build_configurations.each do |config|
			config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
		end
		if target.name == 'SwiftPrelude'
			target.build_configurations.each do |config|
				config.build_settings['SWIFT_VERSION'] = '4.2'
			end
		end
	end
end
