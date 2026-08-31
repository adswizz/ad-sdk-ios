Pod::Spec.new do |s|
  s.name        = "AdswizzSDK"
  s.version     = "8.0.0"
  s.summary     = "Audio Ad serving SDK"
  s.description = <<-DESC
                  The only audio-centric SDK to Drive Innovation & Differentiation in Audio monetization
                  DESC
  s.homepage    = "http://adswizz.com"

  s.license     = {
     :type => 'Copyright',
     :text => <<-LICENSE
       Copyright 2024 AdsWizz, Inc. All rights reserved.
       LICENSE
  }
  s.author      = { "AdsWizz, Inc" => "sdk@adswizz.com" }

  s.ios.deployment_target = '13.0'
  s.tvos.deployment_target = '13.0'
  s.swift_versions = ['6.3.1']

s.source = { :git => "https://github.com/adswizz/ad-sdk-ios.git", :tag => "8.0.0" }

  s.vendored_frameworks = 'Framework/AdswizzSDK.xcframework', 'Framework/AdswizzSDKCore.xcframework'
  s.requires_arc = true

end
