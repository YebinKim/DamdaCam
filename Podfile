project 'DamdaCam.xcodeproj'

# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

def pods_all_targets
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
	pod 'lottie-ios'

  # Pods for GoogleAR frameworks
	pod 'ARCore',  '~> 1.4'

  # Face Detection frameworks
	pod 'Metron', '~> 1.0'
    
  # Color Picker frameworks
  	pod 'FlexColorPicker', '~> 1.4'
  
  # Lint
  pod 'SwiftLint'

end

target 'DamdaCam' do
	pods_all_targets

end

# Addresses bug with XCode 9 and app icons https://github.com/CocoaPods/CocoaPods/issues/7003
post_install do |installer|
    installer.pods_project.targets.each do |t|
      t.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      end
    end
    copy_pods_resources_path = "Pods/Target Support Files/Pods-DamdaCam/Pods-DamdaCam-resources.sh"
    string_to_replace = '--compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"'
    assets_compile_with_app_icon_arguments = '--compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" --app-icon "${ASSETCATALOG_COMPILER_APPICON_NAME}" --output-partial-info-plist "${BUILD_DIR}/assetcatalog_generated_info.plist"'
    text = File.read(copy_pods_resources_path)
    new_contents = text.gsub(string_to_replace, assets_compile_with_app_icon_arguments)
    File.open(copy_pods_resources_path, "w") {|file| file.puts new_contents }

end
