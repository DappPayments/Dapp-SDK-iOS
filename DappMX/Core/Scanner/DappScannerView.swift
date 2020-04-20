//
//  DappScannerView.swift
//  DappMX
//
//  Created by Rodrigo Rivas on 3/23/20.
//  Copyright © 2020 Dapp. All rights reserved.
//

import UIKit
import AVFoundation

public protocol DappScannerViewDelegate: AnyObject {
    func dappScannerView(_ scannerView: DappScannerView, didScanCode code: String)
    func dappScannerView(_ scannerView: DappScannerView, didFailWithError error: DappError)
}

public class DappScannerView: UIView, AVCaptureMetadataOutputObjectsDelegate {
    
    public weak var delegate: DappScannerViewDelegate?
    public var showQRFrame: Bool = true
    public var successFrameColor: UIColor = .green
    public var failureFrameColor: UIColor = .red

    private lazy var drawLayer = CALayer()
    private lazy var captureSession = AVCaptureSession()
    private var overlayLayer: CAShapeLayer?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var parentViewController: UIViewController?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        setScanner()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        guard let previewBounds = videoPreviewLayer?.bounds else {
            return
        }
        
        if previewBounds.width != frame.width || previewBounds.height != frame.height {
            videoPreviewLayer?.frame = bounds
        }
    }

    private func setScanner() {
        guard let device = AVCaptureDevice.default(for: .video), let input = try? AVCaptureDeviceInput(device: device) else {
            delegate?.dappScannerView(self, didFailWithError: .cameraNotAllowed)
            return
        }
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        let output = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
        output.setMetadataObjectsDelegate(self, queue: .main)
        output.metadataObjectTypes = [.qr]
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = .resizeAspectFill
        //videoPreviewLayer?.frame = layer.bounds
        layer.addSublayer(videoPreviewLayer!)
        drawLayer.frame = layer.bounds
        layer.addSublayer(drawLayer)
    }
    
    public func startScanning() {
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveDeviceOrientationNotification), name: UIDevice.orientationDidChangeNotification, object: UIDevice.current)
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
        removeDrawLayers()
    }
    
    public func isScanning() -> Bool {
        return captureSession.isRunning
    }
    
    public func stopScanning() {
        NotificationCenter.default.removeObserver(self)
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    public func qrScannedFailed() {
        overlayLayer?.strokeColor = failureFrameColor.cgColor
    }
    
    private func removeDrawLayers() {
        guard let layers = drawLayer.sublayers else {
            return
        }
        for l in layers {
            l.removeFromSuperlayer()
        }
    }
    
    @objc private func didReceiveDeviceOrientationNotification() {
        if let conn = videoPreviewLayer?.connection {
            switch UIDevice.current.orientation {
            case .portrait:
                if (supportedOrientationsMask().rawValue & UIInterfaceOrientationMask.portrait.rawValue) != 0 {
                    conn.videoOrientation = .portrait
                }
            case .portraitUpsideDown:
                if (supportedOrientationsMask().rawValue & UIInterfaceOrientationMask.portraitUpsideDown.rawValue) != 0 {
                    conn.videoOrientation = .portraitUpsideDown
                }
            case .landscapeRight:
                if (supportedOrientationsMask().rawValue & UIInterfaceOrientationMask.landscapeLeft.rawValue) != 0 {
                    conn.videoOrientation = .landscapeLeft
                }
            case .landscapeLeft:
                if (supportedOrientationsMask().rawValue & UIInterfaceOrientationMask.landscapeRight.rawValue) != 0 {
                    conn.videoOrientation = .landscapeRight
                }
            default:
                break
            }
        }
    }
    
    private func supportedOrientationsMask() -> UIInterfaceOrientationMask {
        if parentViewController == nil {
            var responder = next
            while responder != nil && !responder!.isKind(of: UIViewController.self) {
                responder = responder?.next
            }
            parentViewController = responder as? UIViewController
        }
        
        var plistMask: UIInterfaceOrientationMask = .all
        guard let vc = parentViewController else {
            return plistMask
        }
        
        if let mask = UIApplication.shared.delegate?.application?(UIApplication.shared, supportedInterfaceOrientationsFor: window) {
            plistMask = mask
        }
        else if let maskArray = Bundle.main.object(forInfoDictionaryKey: "UISupportedInterfaceOrientations") as? [String] {
            var tempMask: UInt = 0
            for supportedOrientation in maskArray {
                if supportedOrientation == "UIInterfaceOrientationPortrait" {
                    tempMask |= UIInterfaceOrientationMask.portrait.rawValue
                }
                else if supportedOrientation == "UIInterfaceOrientationPortraitUpsideDown" {
                    tempMask |= UIInterfaceOrientationMask.portraitUpsideDown.rawValue
                }
                else if supportedOrientation == "UIInterfaceOrientationLandscapeLeft" {
                    tempMask |= UIInterfaceOrientationMask.landscapeLeft.rawValue
                }
                else if supportedOrientation == "UIInterfaceOrientationLandscapeRight" {
                    tempMask |= UIInterfaceOrientationMask.landscapeRight.rawValue
                }
            }
            plistMask = UIInterfaceOrientationMask(rawValue: tempMask)
        }
        
        return UIInterfaceOrientationMask(rawValue: plistMask.rawValue & vc.supportedInterfaceOrientations.rawValue)
    }
    
    //MARK: - AVCaptureMetadataOutputObjectsDelegate
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObj = metadataObjects.first as? AVMetadataMachineReadableCodeObject, metadataObj.type == .qr, let code = metadataObj.stringValue else {
            return
        }
        if showQRFrame, let qrObj = videoPreviewLayer?.transformedMetadataObject(for: metadataObj) as? AVMetadataMachineReadableCodeObject {
            drawCodeCorners(object: qrObj)
        }
        delegate?.dappScannerView(self, didScanCode: code)
    }
    
    private func drawCodeCorners(object: AVMetadataMachineReadableCodeObject) {
        if object.corners.count == 0 {
            return
        }
        
        overlayLayer = CAShapeLayer()
        overlayLayer?.lineWidth = 4
        overlayLayer?.strokeColor = UIColor.green.cgColor
        overlayLayer?.fillColor = UIColor.clear.cgColor
        overlayLayer?.path = createPath(from: object.corners).cgPath
        drawLayer.addSublayer(overlayLayer!)
    }
    
    private func createPath(from points: [CGPoint]) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: points.first!)
        var i = 1
        while i < points.count {
            path.addLine(to: points[i])
            i += 1
        }
        path.close()
        return path
    }
}
