Pod::Spec.new do |s|
  s.name        = "AdswizzSDK"
  s.version     = "7.7.12"
  s.summary     = "Audio Ad serving SDK"
  s.description = <<-DESC
                  The only audio-centric SDK to Drive Innovation & Differentiation in Audio monetization
                  DESC
  s.homepage    = "http://adswizz.com"

  s.license     = {
     :type => 'Copyright',
     :text => <<-LICENSE
       Copyright 2020 AdsWizz, Inc. All rights reserved.
       LICENSE
  }
  s.author      = { "AdsWizz, Inc" => "sdk@adswizz.com" }

  s.platform    = :ios
  s.ios.deployment_target = '11.0'
  s.swift_versions = ['5.6.1']

s.source = { :git => "https://github.com/adswizz/ad-sdk-ios.git", :tag => "release/7.7.12" }

  s.vendored_frameworks = 'Framework/AdswizzSDK.xcframework'
  s.requires_arc = true

  s.dependency 'AWSCore'
  s.dependency 'AdswizzSDKPrivacyData', '1.0.6'
end
