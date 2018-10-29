#
# Be sure to run `pod lib lint TPFeatureTag.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TPFeatureTag'
  s.version          = '0.1.0'
  s.summary          = 'Simple boolean feature tags manager.'
  s.description      = <<-DESC
Simple boolean feature tags manager with name spaced feature tags and custom value resolvers
                       DESC

  s.homepage         = 'https://github.com/threeplay/TPFeatureTag'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Eliran Ben-Ezra' => 'eliran@threeplay.com' }
  s.source           = { :git => 'https://github.com/threeplay/TPFeatureTag.git', :tag => s.version.to_s }
  s.swift_version    = '4.2'
  s.ios.deployment_target = '10.0'

  s.source_files = 'TPFeatureTag/Classes/**/*'
end
