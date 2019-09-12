Pod::Spec.new do |s|
  s.name        = "AdswizzAdSDK"
  s.version      = "0.0.15"
  s.summary      = "Audio Ad serving SDK"
  s.description  = <<-DESC
                  Serves VAST ads to Adswizz client iOS apps for non-sophisticated clients
                  DESC
  s.homepage    = "http://adswizz.com"

  s.license      = {
    :type => 'Copyright',
    :text => <<-LICENSE
      Copyright 2019 AdsWizz, Inc. All rights reserved.
      LICENSE
  }

  s.author      = { "AdsWizz, Inc" => "teodor.cristea@adswizz.com" }
  s.social_media_url  = "http://twitter.com/adswizz"

  s.platform    = :ios
  s.ios.deployment_target = '11.0'

  s.source      = { :git => "https://github.com/teodor-adw/AdswizzAdSDK.git", :tag => s.version }
  #s.source_files =  'AudioAdSDK/AudioAdSDK.framework/AudioAdSDK/AudioAdSDK/**/*.swift'

  #s.resources = 'AdswizzAdSDK/AudioAdSDK/Resources/*'
  #s.preserve_paths = 'AudioAdSDK/AudioAdSDK.framework'
  s.vendored_frameworks = 'AudioAdSDK.framework'

  #s.frameworks = 'CoreMotion', 'AudioToolbox', 'MediaPlayer' 
  s.requires_arc = true
  
end
