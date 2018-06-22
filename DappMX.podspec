Pod::Spec.new do |s|
  s.name         = "DappMX"
  s.version      = "1.1.0"
  s.summary      = "Dapp is an online payment platform from Mexico"
  s.description  = <<-DESC
Dapp is an online payment platform, focused on the security of its users. This is the easiest way to integrate Dapp into your iOS application. DappMX has two functionalities, tokenize credit and debit cards so you can make future charges. Through this SDK you can also make payments directly in the Dapp app.
                   DESC
  s.homepage     = "https://dapp.mx"
  s.license      = "MIT"
  s.author             = { "Dapp Payments" => "devs@dapp.mx" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/DappPayments/Dapp-SDK-iOS.git", :tag => s.version.to_s }
  s.source_files  = "dapp-sdk-ios", "dapp-sdk-ios/*.{h,m,swift}"
  s.resources = "dapp-sdk-ios/*.{png,pem,xib}"
  s.swift_version = "4.0"
end
