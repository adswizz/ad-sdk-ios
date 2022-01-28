Pod::Spec.new do |s|
  s.name        = "AdswizzWatchSDK"
  s.version     = "7.6.3"
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
  s.swift_versions = ['5.3.2']

  s.source      = { :git => "git@gitlab.adswizz.com:sdk/ad-sdk-ios-develop.git", :branch => "prerelease/7.6.3" }

  s.vendored_frameworks = 'Framework/AdswizzWatchSDK.xcframework'
  s.requires_arc = true
end
