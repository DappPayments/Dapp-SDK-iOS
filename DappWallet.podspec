Pod::Spec.new do |spec|

  spec.name         = "DappWallet"
  spec.version      = "2.0.0"
  spec.summary      = "Dapp is the new payments network in Mexico."

  spec.description  = <<-DESC
Wallets that use this SDK will be able to read Dapp POS QR Codes and get the information associated with them. They will also be able to create Dapp RP Codes and follow their status.
                   DESC

  spec.homepage      = "https://dapp.mx"
  spec.license       = { :type => "MIT", :file => "LICENSE.txt" }
  spec.author        = { "Dapp Payments" => "devs@dapp.mx" }
  spec.platform      = :ios, "11.0"
  spec.source        = { :git => "https://github.com/DappPayments/Dapp-SDK-iOS.git",
			 :tag => "Wallet-" + spec.version.to_s }
  spec.source_files  = "DappMX/Core/*.swift", "DappMX/Core/**/*.swift", "DappMX/Wallet/*.swift", "DappMX/Wallet/**/*.swift"
  spec.swift_version    = "5"
  spec.default_subspecs = :none
  spec.cocoapods_version = ">= 1.9.0"

  spec.subspec "Socket" do |ss|
    ss.source_files  = "DappMX/Core/*.swift", "DappMX/Core/**/*.swift", "DappMX/Wallet/*.swift", "DappMX/Wallet/**/*.swift"
    ss.dependency "Starscream", "~> 3.0.2"
  end
end
