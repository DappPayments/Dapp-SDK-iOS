//
//  DappScannerViewController.swift
//  DappMX
//
//  Created by Rodrigo Rivas on 3/23/20.
//  Copyright © 2020 Dapp. All rights reserved.
//

import UIKit

public protocol DappScannerViewControllerDelegate: AnyObject {
    
    func dappScannerViewController(_ viewController: DappScannerViewController, didFailWithError error: DappError)
}

public class DappScannerViewController: UIViewController, DappScannerViewDelegate {
    
    private var scannerView: DappScannerView!
    private var loadingView: DappLoadingView!
    private var btnCancel: UIButton!
    private var didLayoutSubviews = false
    
    override public func viewDidLoad() {
       super.viewDidLoad()
        scannerView = DappScannerView()
        scannerView.delegate = self
        scannerView.frame = view.frame
        scannerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(scannerView)
    }
    
    override public func viewDidLayoutSubviews() {
        if !didLayoutSubviews {
            didLayoutSubviews = true
            startScanning()
        }
        if btnCancel == nil {
            btnCancel = UIButton(type: .system)
            btnCancel.frame.origin = CGPoint(x: 8, y: view.layoutMargins.top + 8)
            btnCancel.setTitle("Cancelar", for: .normal)
            btnCancel.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            btnCancel.setTitleColor(.white, for: .normal)
            btnCancel.sizeToFit()
            btnCancel.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
            view.addSubview(btnCancel)
        }
    }
    
    internal func startScanning() {
        scannerView.startScanning()
    }
    
    internal func stopsScanning() {
        scannerView.stopScanning()
    }
    
    internal func showLoader() {
        if loadingView == nil {
            loadingView = DappLoadingView(frame: CGRect(x: view.frame.midX - 50, y: view.frame.midY - 50, width: 100, height: 100))
            view.addSubview(loadingView)
        }
        loadingView.show()
    }
    
    internal func hideLoader() {
        if let lv = loadingView {
            lv.hide()
        }
    }
    
    internal func qrScannedFailed() {
        scannerView.qrScannedFailed()
    }
    
    @objc internal func didTapCancelButton() {
        scannerView.stopScanning()
        dismiss(animated: true)
    }
    
    //MARK: - DappScannerViewDelegate
    open func dappScannerView(_ scannerView: DappScannerView, didScanCode code: String) { }
    
    open func dappScannerView(_ scannerView: DappScannerView, didFailWithError error: DappError) { }
}
