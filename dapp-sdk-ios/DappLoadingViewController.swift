//
//  DappLoadingViewController.swift
//  Dapp SDK iOS
//
//  Created by Rodrigo Rivas Torres on 24/07/17.
//  Copyright © 2017 Dapp. All rights reserved.
//

import UIKit

internal class DappLoadingViewController: UIViewController {

    @IBOutlet var lblStatus: UILabel!
    var urlScheme: String!
    var amount: Double!
    var paymentDesc: String!
    var reference: String?
    var requestCancelled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let btnCancel = UIBarButtonItem(title: "Cancelar", style: .plain, target: self, action: #selector(DappLoadingViewController.cancel))
        self.navigationItem.leftBarButtonItem = btnCancel
        NotificationCenter.default.addObserver(self, selector: #selector(DappLoadingViewController.dappCallback), name: Dapp.callbackNotification, object: nil)
        
        let handler: ResponseHandler = { data, error in
            if let e = error {
                self.setLabel(text: "Error al procesar pago")
                self.dismiss(animated: true, completion: { 
                    Dapp.shared.paymentDelegate?.dappPaymentFailure(error: e)
                })
                return
            }
            
            guard let code = data?["short_code"] as? String else {
                self.dismiss(animated: true, completion: {
                    self.setLabel(text: "Error al procesar pago")
                    Dapp.shared.paymentDelegate?.dappPaymentFailure(error: .responseError(msg: nil))
                })
                return
            }
            
            if self.requestCancelled {
                return
            }
            
            self.setLabel(text: "Abriendo Dapp...")
            let url = URL(string: "dappmx://payment?code=\(code)&origin=\(self.urlScheme!)")!
            UIApplication.shared.openURL(url)
        }
        
        var params = "amount=\(amount!)&description=\(paymentDesc!)"
        if let r = reference {
            params = "\(params)&reference=\(r)"
        }
        
        Dapp.dappRequest(url: "\(Dapp.shared.enviroment.getServer())dapp-codes/", params: params, handler: handler)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Dapp.callbackNotification, object: nil)
    }
    
    @objc func dappCallback() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setLabel(text: String) {
        DispatchQueue.main.async {
            self.lblStatus.text = text
        }
    }
    
    @objc func cancel() {
        self.dismiss(animated: true, completion: {
            self.requestCancelled = true
            Dapp.shared.paymentDelegate?.dappPaymentFailure(error: .userCanceled)
        })
    }

}
