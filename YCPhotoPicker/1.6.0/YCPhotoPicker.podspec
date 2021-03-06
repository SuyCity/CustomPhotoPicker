#
# Be sure to run `pod lib lint YCPhotoPicker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "YCPhotoPicker"
  s.version          = "1.6.0"
  s.summary          = "This is a copy of the album QQ photos picker"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
This is a copy of the album QQ photos picker.
1 support multi radio.
2 using AutoLayout layout, support for all iPhone, iPad.
3 optimize the memory, 1000 photos will not be card.
4 a code to get.
                       DESC

  s.homepage         = "https://github.com/Suycity/CustomPhotoPicker"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Suycity" => "suycity@gmail.com" }
  s.source           = { :git => "https://github.com/Suycity/CustomPhotoPicker.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/suycity1'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'YCPhotoPicker' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
