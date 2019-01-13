#
# Be sure to run `pod lib lint TGBAnyObject.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TGBAnyObject'
  s.version          = '0.1.1'
  s.summary          = '万能转换'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
                     here is description.
                       DESC

  s.homepage         = 'https://github.com/956409020/TGBAnyObject'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '95640902012' => '95640902012@qq.com' }
  s.source           = { :git => 'https://github.com/956409020/TGBAnyObject.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'
  
  s.public_header_files = ["Sources/**/*.h","Sources/*/**/*.h","Sources/*/*/**/*.h","Sources/*/*/*/**/*.h","Sources/*/*/*/*/**/*.h","Sources/*/*/*/*/*/**/*.h","Sources/*/*/*/*/*/*/**/*.h"]
  
  s.source_files = ["Sources/**","Sources/*/**","Sources/*/*/**","Sources/*/*/*/**","Sources/*/*/*/*/**","Sources/*/*/*/*/*/**","Sources/*/*/*/*/*/*/**"]
  
 #   s.resource_bundles = {
 #     'Asserts' => ['Asserts.bundle/*.png']
 #   }
  
  s.requires_arc = true
  
  s.frameworks = 'UIKit','Foundation'
  
  #  s.dependency 'FHXEmptyPage'
 
  
  #  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0' }
  
end
