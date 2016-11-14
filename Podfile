# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'a160 West Chester UMC' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for a160 West Chester UMC
	    pod 'SnapKit', '~> 3.0.0'
    pod 'STPopup'
    pod 'JASON', '~> 3.0'
    pod 'SwiftyJSON'
    pod 'ChameleonFramework'
    pod 'SVProgressHUD'
    pod 'DrawerController'
    pod 'DZNEmptyDataSet'
    pod 'CryptoSwift', :git => "https://github.com/krzyzanowskim/CryptoSwift", :branch => "master"
    pod 'Alamofire', '~> 4.0'
    pod 'AlamofireImage', '~> 3.0'
    pod 'Eureka', :git => "https://github.com/xmartlabs/Eureka", :branch => "master"
    pod 'AWSCore'
    pod 'AWSMobileAnalytics'
    pod 'Whisper'
    post_install do |installer|
      installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
          config.build_settings['SWIFT_VERSION'] = '3.0'
        end
      end
    end

end
