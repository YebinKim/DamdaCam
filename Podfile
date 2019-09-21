project 'DamdaCam.xcodeproj'

# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

def pods_all_targets
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
	pod 'lottie-ios'
	pod 'Reachability', '~> 3.2'

  # Pods for GoogleAR frameworks
	pod 'ARCore',  '~> 1.4.0'
	pod 'GTMSessionFetcher/Core', '~> 1.1'
	pod 'GoogleToolboxForMac/Logger', '~> 2.1'
	pod 'GoogleToolboxForMac/NSData+zlib', '~> 2.1'
	pod 'Protobuf', '~> 3.5'
  pod 'gRPC-ProtoRPC', '~> 1.0'

  # Face Detection frameworks
	pod 'Metron', '~> 1.0.2'
    
  # Color Picker frameworks
  pod 'FlexColorPicker', '~> 1.2.1'

end

target 'DamdaCam' do
	pods_all_targets

end

# Addresses bug with XCode 9 and app icons https://github.com/CocoaPods/CocoaPods/issues/7003
post_install do |installer|
    copy_pods_resources_path = "Pods/Target Support Files/Pods-DamdaCam/Pods-DamdaCam-resources.sh"
    string_to_replace = '--compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"'
    assets_compile_with_app_icon_arguments = '--compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" --app-icon "${ASSETCATALOG_COMPILER_APPICON_NAME}" --output-partial-info-plist "${BUILD_DIR}/assetcatalog_generated_info.plist"'
    text = File.read(copy_pods_resources_path)
    new_contents = text.gsub(string_to_replace, assets_compile_with_app_icon_arguments)
    File.open(copy_pods_resources_path, "w") {|file| file.puts new_contents }

end
