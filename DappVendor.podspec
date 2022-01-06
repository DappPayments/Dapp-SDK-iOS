Pod::Spec.new do |spec|

  spec.name         = "DappVendor"
  spec.version      = "2.5.2"
  spec.summary      = "Dapp is the new payments network in Mexico."

  spec.description  = <<-DESC
Businesses integrated in the Dapp environment can use this SDK to create Dapp POS QR Codes for their clients to pay. They can also read Dapp RP Codes from their clients and charge them.
                   DESC

  spec.homepage      = "https://dapp.mx"
  spec.license       = { :type => "MIT", :file => "LICENSE.txt" }
  spec.author        = { "Dapp Payments" => "devs@dapp.mx" }
  spec.platform      = :ios, "11.0"
  spec.source        = { :git => "https://github.com/DappPayments/Dapp-SDK-iOS.git",
			 :tag => "Vendor-" + spec.version.to_s }
  spec.source_files  = "DappMX/Core/*.swift", "DappMX/Core/**/*.swift", "DappMX/Vendor/*.swift", "DappMX/Vendor/**/*.swift"
  spec.exclude_files = "DappMX/Core/DappCardProtocol.swift"
  spec.swift_version    = "5"
  spec.default_subspecs = :none
  spec.cocoapods_version = ">= 1.9.0"

  spec.subspec "Socket" do |ss|
    ss.source_files  = "DappMX/Core/*.swift", "DappMX/Core/**/*.swift", "DappMX/Vendor/*.swift", "DappMX/Vendor/**/*.swift"
    ss.exclude_files = "DappMX/Core/DappCardProtocol.swift"
    ss.dependency "Starscream", "~> 3.0.2"
  end
end
