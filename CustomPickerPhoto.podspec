Pod::Spec.new do |s|

  s.name = 'CustomPickerPhoto'
  s.version = '1.0.0'
  s.license = 'MIT'
  s.summary = 'Photos'
  s.description = <<-DESCRIPTION
                        Custom Picker Photos
                  DESCRIPTION

  s.homepage = 'https://github.com/SuyCity/CustomPhotoPicker'
  s.author = { 'Michael Waterfall' => 'suycity@gmail.com' }
  s.social_media_url = 'https://twitter.com/suycity1'

  s.source = {
    :git => 'https://github.com/SuyCity/CustomPhotoPicker.git',
    :tag => '1.0.0'
  }
  s.platform = :ios, '7.0'
  s.source_files = 'YCPhotoPicker/**/*'
  s.resource_bundles = {
    'CustomPickerPhoto' => ['YCPhotoPicker/Resources/*.png']
  }
  s.requires_arc = true

  s.frameworks = 'UIKit','AssetsLibrary', 'Foundation'
#s.weak_frameworks = 'Photos'

#s.dependency 'MBProgressHUD', '~> 0.9'
#s.dependency 'DACircularProgress', '~> 2.3'

  # SDWebImage
  # 3.7.2 contains bugs downloading local files
  # https://github.com/rs/SDWebImage/issues/1109
  #s.dependency 'SDWebImage', '~> 3.7', '!= 3.7.2'

end
