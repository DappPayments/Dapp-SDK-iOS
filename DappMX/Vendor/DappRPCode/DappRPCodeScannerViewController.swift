//
//  DappRPCodeScannerViewController.swift
//  DappMX
//
//  Created by Rodrigo Rivas on 3/30/20.
//  Copyright © 2020 Dapp. All rights reserved.
//

import UIKit

public protocol DappRPCodeScannerViewControllerDelegate: DappScannerViewControllerDelegate {
    
    func dappScannerViewController(_ viewController: DappScannerViewController, didReceivePayment payment: DappPayment)
}

public class DappRPCodeScannerViewController: DappScannerViewController {
    
    public weak var delegate: DappRPCodeScannerViewControllerDelegate?
    private var amount: Double
    private var paymentDescription: String
    private var reference: String?

    public init(amount: Double, description: String, reference: String? = nil) {
        self.amount = amount
        self.paymentDescription = description
        self.reference = reference
        super.init(nibName: nil, bundle: nil)
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
        let rpCode = DappRPCode(code)
        rpCode.charge(amount, description: paymentDescription, reference: reference) { [weak self] (payment, error) in
            guard let viewController = self else {
                return
            }
            viewController.hideLoader()
            if let e = error {
                viewController.delegate?.dappScannerViewController(viewController, didFailWithError: e)
                viewController.qrScannedFailed()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                    self?.startScanning()
                }
                return
            }
            if let p = payment {
                viewController.delegate?.dappScannerViewController(viewController, didReceivePayment: p)
                return
            }
            viewController.delegate?.dappScannerViewController(viewController, didFailWithError: .responseError(message: nil))
        }
    }
    
    override public func dappScannerView(_ scannerView: DappScannerView, didFailWithError error: DappError) {
        delegate?.dappScannerViewController(self, didFailWithError: error)
    }
}
