Pod::Spec.new do |s|
  s.name        = "AdswizzWatchSDK"
  s.version     = "7.6.2"
  s.summary     = "Adswizz Watch SDK"
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

  s.platform    = :watchos
  s.watchos.deployment_target = '6.1'
  s.swift_versions = ['5.5.1']

s.source      = { :git => "https://github.com/adswizz/ad-sdk-ios.git", :tag => "release/7.6.2" }

  s.vendored_frameworks = 'Framework/AdswizzWatchSDK.xcframework'
  s.requires_arc = true
end
