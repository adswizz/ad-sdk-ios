Pod::Spec.new do |s|
  s.name        = "AdswizzAdSDK"
  s.version      = "0.0.7"
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

  s.platform    = :ios
  s.ios.deployment_target = '11.0'

  s.source      = { :git => "https://github.com/adswizz/ad-sdk-ios.git", :tag => s.version }

  s.vendored_frameworks = 'Framework/AdswizzAdSDK.framework'
  s.requires_arc = true
  
  s.dependency 'AWSCore'
  s.dependency 'SocketRocket'
  
end
