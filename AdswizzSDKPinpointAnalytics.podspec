Pod::Spec.new do |s|
  s.name        = "AdswizzSDKPinpointAnalytics"
  s.version     = "7.9.0"
  s.summary     = "Pinpoint Analytics SDK to be linked to AdswizzSDK"
  s.description = <<-DESC
                  The AdswizzSDKPinpointAnalytics framework adds support for the AWS Pinpoint service and links it to the AdswizzSDK Analytics
                  DESC
  s.homepage    = "http://adswizz.com"

  s.license     = {
     :type => 'Copyright',
     :text => <<-LICENSE
       Copyright 2023 AdsWizz, Inc. All rights reserved.
       LICENSE
  }
  s.author      = { "AdsWizz, Inc" => "sdk@adswizz.com" }

  s.platform    = :ios
  s.ios.deployment_target = '11.0'
  s.swift_versions = ['5.9.2']

s.source = { :git => "https://github.com/adswizz/ad-sdk-ios.git", :tag => "release/7.9.0" }

  s.vendored_frameworks = 'Framework/AdswizzSDKPinpointAnalytics.xcframework'
  s.requires_arc = true

  s.dependency 'AWSCore'
end
