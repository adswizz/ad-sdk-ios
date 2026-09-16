Pod::Spec.new do |s|
  s.name        = "AdswizzWatchSDK"
  s.version     = "8.0.1"
  s.summary     = "Adswizz Watch SDK"
  s.description = <<-DESC
                  The only audio-centric SDK to Drive Innovation & Differentiation in Audio monetization
                  DESC
  s.homepage    = "https://sdk.adswizz.com/#/"

  s.license     = { :type => 'Copyright', :file => 'LICENSE' }
  s.author      = { "AdsWizz, Inc" => "sdk@adswizz.com" }

  s.platform    = :watchos
  s.watchos.deployment_target = '6.1'
  s.swift_versions = ['6.3.1']

s.source = { :git => "https://github.com/adswizz/ad-sdk-ios.git", :tag => "8.0.1" }

  s.vendored_frameworks = 'Framework/AdswizzWatchSDK.xcframework'
  s.requires_arc = true
end
