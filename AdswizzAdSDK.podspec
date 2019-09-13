Pod::Spec.new do |s|
  s.name        = "AdswizzAdSDK"
  s.version      = "0.0.1"
  s.summary      = "Audio Ad serving SDK"
  s.description  = <<-DESC
                  The only audio-centric SDK to Drive Innovation & Differentiation in Audio monetization
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

  s.source      = { :git => "https://github.com/adswizz/adswizz-ad-sdk-releases.git", :tag => s.version }

  s.vendored_frameworks = 'Framework/AudioAdSDK.framework' 
  s.requires_arc = true
  
  s.dependency 'AWSCore'
  s.dependency 'SocketRocket', :inhibit_warnings => true
  
end
