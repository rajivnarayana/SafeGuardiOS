#
# Be sure to run `pod lib lint SafeGuardiOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SafeGuardiOS'
  s.version          = '0.1.0'
  s.summary          = 'A short description of SafeGuardiOS.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/Rajiv Singaseni/SafeGuardiOS'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Rajiv Singaseni' => 'rajiv@webileapps.com' }
  s.source           = { :git => 'https://github.com/Rajiv Singaseni/SafeGuardiOS.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'

  s.source_files = 'SafeGuardiOS/Classes/**/*'
  
  s.resource_bundles = {'SGSecurityPrivacy' => ['SafeGuardiOS/Resources/PrivacyInfo.xcprivacy']}
  
  # s.resource_bundles = {
  #   'SafeGuardiOS' => ['SafeGuardiOS/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.ios.frameworks = 'UIKit', 'Foundation'
  s.requires_arc = true
  # s.dependency 'AFNetworking', '~> 2.3'
end
