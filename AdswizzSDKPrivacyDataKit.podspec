Pod::Spec.new do |s|
  s.name        = "AdswizzSDKPrivacyDataKit"
  s.version     = "7.14.3"
  s.summary     = "Optional helper kit framework which provides transparent support for Privacy-Sensitive Data API"
  s.description = <<-DESC
                  The solution for iOS App rejection on AppStore due to lack of string description in app's Info.plist.
                  Check: https://developer.apple.com/library/archive/qa/qa1937/_index.html
                  AdswizzSDKPrivacyDataCore is a helper framework for AdswizzSDK on iOS that has all the Privacy-Sensitive API required by AdswizzSDK.xcframework. 
                  AdswizzSDKPrivacyDataCore's purpose is to facilitate the interoperability with AdswizzSDK and to allow your app to manage sensitive APIs (such as permission APIs) without adding unwanted permission usage decription strings in the app's Info.plist manifest. 
                  It is a transparent way to communicate to AdswizzSDK all your app-specific Privacy needs and constraints.
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
  s.swift_versions = ['5.10.0']

s.source = { :git => "https://github.com/adswizz/ad-sdk-ios.git", :tag => "7.14.3" }
  s.requires_arc = true

  # The default subspec which will be installed automatically.
  s.default_subspec = 'Core'

  # Core subspec
  s.subspec 'Core' do |core|
     core.vendored_frameworks = 'Framework/AdswizzSDKPrivacyDataCore.xcframework'
  end

  # Optional subspecs

  # AdswizzSDKPrivacyDataIDFA
  s.subspec 'IDFA' do |idfa|
     idfa.source_files = 'AdswizzSDKPrivacyDataKit/AdswizzSDKPrivacyDataIDFA/**/*.{swift, h}'
     idfa.dependency 'AdswizzSDKPrivacyDataKit/Core'
  end

  # AdswizzSDKPrivacyDataMicrophone
  s.subspec 'Microphone' do |microphone|
     microphone.source_files = 'AdswizzSDKPrivacyDataKit/AdswizzSDKPrivacyDataMicrophone/**/*.{swift, h}'
     microphone.dependency 'AdswizzSDKPrivacyDataKit/Core'
  end

  # AdswizzSDKPrivacyDataSpeech
  s.subspec 'Speech' do |speech|
     speech.platform = :ios
     speech.source_files = 'AdswizzSDKPrivacyDataKit/AdswizzSDKPrivacyDataSpeech/**/*.{swift, h}'
     speech.dependency 'AdswizzSDKPrivacyDataKit/Core'
  end

  # AdswizzSDKPrivacyDataPhotos
  s.subspec 'Photos' do |photo|
     photo.source_files = 'AdswizzSDKPrivacyDataKit/AdswizzSDKPrivacyDataPhotos/**/*.{swift, h}'
     photo.dependency 'AdswizzSDKPrivacyDataKit/Core'
  end

  # AdswizzSDKPrivacyDataLocation
  s.subspec 'Location' do |location|
     location.source_files = 'AdswizzSDKPrivacyDataKit/AdswizzSDKPrivacyDataLocation/**/*.{swift, h}'
     location.dependency 'AdswizzSDKPrivacyDataKit/Core'
  end

  # AdswizzSDKPrivacyDataCalendar
  s.subspec 'Calendar' do |calendar|
     calendar.platform = :ios
     calendar.source_files = 'AdswizzSDKPrivacyDataKit/AdswizzSDKPrivacyDataCalendar/**/*.{swift, h}'
     calendar.dependency 'AdswizzSDKPrivacyDataKit/Core'
  end

  # AdswizzSDKPrivacyDataMotion
  s.subspec 'Motion' do |motion|
     motion.platform = :ios
     motion.source_files = 'AdswizzSDKPrivacyDataKit/AdswizzSDKPrivacyDataMotion/**/*.{swift, h}'
     motion.dependency 'AdswizzSDKPrivacyDataKit/Core'
  end

  # AdswizzSDKPrivacyDataContacts
  s.subspec 'Contacts' do |contact|
     contact.platform = :ios
     contact.source_files = 'AdswizzSDKPrivacyDataKit/AdswizzSDKPrivacyDataContacts/**/*.{swift, h}'
     contact.dependency 'AdswizzSDKPrivacyDataKit/Core'
  end

  # AdswizzSDKPrivacyDataCamera
  s.subspec 'Camera' do |camera|
     camera.source_files = 'AdswizzSDKPrivacyDataKit/AdswizzSDKPrivacyDataCamera/**/*.{swift, h}'
     camera.dependency 'AdswizzSDKPrivacyDataKit/Core'
  end
end
