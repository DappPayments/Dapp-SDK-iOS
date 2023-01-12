//
//  DappCheckoutViewController.swift
//  DappCustomer
//
//  Created by Rodrigo Rivas on 03/01/23.
//  Copyright © 2023 Dapp. All rights reserved.
//

import UIKit
import WebKit

public class DappCheckoutViewController: UIViewController, WKScriptMessageHandler {
    
    private var webView: WKWebView!
    private var dappCode: DappCode!
    
    public init(dappCode: DappCode) {
        self.dappCode = dappCode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        let ucc = WKUserContentController()
        ucc.add(self, name: "checkoutResponse")
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController = ucc
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        view = webView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        guard let dappId = dappCode.dappId else {
            dismiss(animated: true, completion: { [weak self] in
                guard let vc = self else {
                    return
                }
                vc.dappCode.delegate?.dappCode(vc.dappCode, didChangeStatus: .error(.dappCodeNotCreated))
            })
            return
        }
        var host = ""
        if Dapp.shared.enviroment == .production {
            host = "https://dapp.mx/c/"
        }
        else {
            host = "https://sandbox.dapp.mx/c/"
        }
        let checkoutURL = URL(string: "\(host)\(dappId)")
        let request = URLRequest(url: checkoutURL!)
        webView.load(request)
    }
    
    //MARK: - WKScriptMessageHandler
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let data = message.body as? [String: Any] else {
            return
        }
        dismiss(animated: true, completion: { [weak self] in
            guard let vc = self else {
                return
            }
            vc.dappCode.delegate?.dappCode(vc.dappCode, didChangeStatus: .payed(DappPayment(with: data)))
        })
    }
}
