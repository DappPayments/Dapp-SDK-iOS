Pod::Spec.new do |spec|

  spec.name         = "DappCustomer"
  spec.version      = "2.2.0"
  spec.summary      = "Dapp is the new payments network in Mexico."

  spec.description  = <<-DESC
DappCustomer has two functionalities:
* Tokenize credit and debit cards for payments inside the Dapp platform.
* Pay through the wallets integrated in the Dapp environment.
                   DESC

  spec.homepage      = "https://dapp.mx"
  spec.license       = { :type => "MIT", :file => "LICENSE.txt" }
  spec.author        = { "Dapp Payments" => "devs@dapp.mx" }
  spec.platform      = :ios, "11.0"
  spec.source        = { :git => "https://github.com/DappPayments/Dapp-SDK-iOS.git",
			 :tag => "Customer-" + spec.version.to_s }
  spec.source_files  = "DappMX/Core/*.swift", "DappMX/Core/**/*.swift", "DappMX/Customer/*.swift"
  # spec.exclude_files = "DappMX/Core/Info.plist"
  spec.resources     = "DappMX/Core/Resources/*.pem"
  spec.swift_version = "5"
end
