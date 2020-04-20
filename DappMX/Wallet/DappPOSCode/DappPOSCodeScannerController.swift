//
//  DappPOSCodeScannerController.swift
//  DappMX
//
//  Created by Rodrigo Rivas on 3/31/20.
//  Copyright © 2020 Dapp. All rights reserved.
//

import UIKit

public protocol DappPOSCodeScannerViewControllerDelegate: DappScannerViewControllerDelegate {
    
    func dappScannerViewController(_ viewController: DappScannerViewController, didScanCode code: DappPOSCode)
}

public class DappPOSCodeScannerViewController: DappScannerViewController {
    
    private weak var delegate: DappPOSCodeScannerViewControllerDelegate?
    
    public init(delegate: DappPOSCodeScannerViewControllerDelegate) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override internal func didTapCancelButton() {
        super.didTapCancelButton()
        delegate?.dappScannerViewController(self, didFailWithError: .userCancelled)
    }
    
    //MARK: - DappScannerViewDelegate
    override public func dappScannerView(_ scannerView: DappScannerView, didScanCode code: String) {
        scannerView.stopScanning()
        showLoader()
        let code = DappPOSCode(code)
        code.read { [weak self] (error) in
            guard let viewController = self else {
                return
            }
            viewController.hideLoader()
            if let e = error {
                viewController.delegate?.dappScannerViewController(viewController, didFailWithError: e)
                viewController.qrScannedFailed()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.startScanning()
                }
                return
            }
            viewController.delegate?.dappScannerViewController(viewController, didScanCode: code)
        }
    }
    
    override public func dappScannerView(_ scannerView: DappScannerView, didFailWithError error: DappError) {
        delegate?.dappScannerViewController(self, didFailWithError: error)
    }
}
