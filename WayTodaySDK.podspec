Pod::Spec.new do |s|

  s.name         = "WayTodaySDK"
  s.version      = "1.0.11"
  s.summary      = "WayToday integration SDK."
  s.description  = <<-DESC
                    WayTodaySDK contains set of interfaces to update Track ID and locations of WayToday online service.
                   DESC
  s.homepage     = "https://github.com/s4ysolutions/WayTodaySDK-iOS"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author           = { "Sergey Dolin" => "sergey@s4y.solutions" }

  s.swift_version = '5.1'
  s.ios.deployment_target     = "12.4"

  s.source       = { :git => "https://github.com/s4ysolutions/WayTodaySDK-iOS", :tag => "#{s.version}" }
  # s.source_files = "WayTodaySDK/Sources", "WayTodaySDK/Sources/**/*.swift"
  s.source_files = "WayTodaySDK/Sources/**/*.swift"

  s.dependency 'CryptoSwift'
  s.dependency 'Rasat'
  s.dependency 'SwiftGRPC'

end
