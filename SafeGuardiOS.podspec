Pod::Spec.new do |s|
  s.name             = 'SafeGuardiOS'
  s.version          = '0.1.7'
  s.summary          = 'A comprehensive iOS security suite for runtime integrity checking and jailbreak detection'

  s.description      = <<-DESC
SafeGuard is a powerful iOS security framework that provides comprehensive runtime integrity checking,
jailbreak detection, and anti-tampering capabilities. Key features include:
* Advanced jailbreak detection
* Runtime integrity verification
* Debugger and reverse engineering detection
* MSHook and code injection prevention
* Network security monitoring
* Emulator detection
                       DESC

  s.homepage         = 'https://github.com/rajivnarayana/SafeGuardiOS'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Rajiv Singaseni' => 'rajiv@webileapps.com' }
  s.source           = { :git => 'https://github.com/rajivnarayana/SafeGuardiOS.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'
  s.source_files = 'SafeGuard/Classes/**/*.{h,m}'
  s.resource_bundles = {
    'SGSecurityPrivacy' => ['SafeGuard/Resources/PrivacyInfo.xcprivacy'],
    'SafeGuard' => ['SafeGuard/Resources/Localizable.strings']
  }

  s.public_header_files = 'SafeGuard/Classes/**/*.h'
  s.ios.frameworks = 'UIKit', 'Foundation'
  s.requires_arc = true
end