#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_tamper_detector.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_tamper_detector'
  s.version          = '1.0.0'
  s.summary          = 'Native Android and iOS runtime security signals for Flutter applications.'
  s.description      = <<-DESC
A Flutter plugin for collecting native root, jailbreak, instrumentation, debugger, installer, and signing-certificate signals.
                       DESC
  s.homepage         = 'https://github.com/kauemurakami/flutter_tamper_detector'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Kauê Murakami' => 'https://github.com/kauemurakami' }
  s.source           = { :path => '.' }
  s.source_files = 'flutter_tamper_detector/Sources/flutter_tamper_detector/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  s.resource_bundles = {'flutter_tamper_detector_privacy' => ['flutter_tamper_detector/Sources/flutter_tamper_detector/PrivacyInfo.xcprivacy']}
end
