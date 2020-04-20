//
//  DappLoadingView.swift
//  DappMX
//
//  Created by Rodrigo Rivas on 3/23/20.
//  Copyright © 2020 Dapp. All rights reserved.
//

import UIKit

internal class DappLoadingView: UIView {
    
    private var backgroundView: UIView!
    private var activityIndicator: UIActivityIndicatorView!
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setUpSubviews()
        alpha = 0
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpSubviews() {
        backgroundView = UIView()
        backgroundView.frame = bounds
        backgroundView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        backgroundView.backgroundColor = .black
        backgroundView.alpha = 0.7
        addSubview(backgroundView)
        activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicator.sizeToFit()
        activityIndicator.center = CGPoint(x: frame.width / 2, y: frame.height / 2)
        activityIndicator.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]
        addSubview(activityIndicator)
        clipsToBounds = true
        layer.cornerRadius = 10
    }
    
    public func show() {
        activityIndicator.startAnimating()
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1
        }
    }
    
    public func hide() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        }) { (completed) in
            if completed {
                self.activityIndicator.stopAnimating()
            }
        }
    }

}
