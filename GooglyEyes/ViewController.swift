//
//  ViewController.swift
//  GooglyEyes
//
//  Created by Aayush Kapoor on 09/10/15.
//  Copyright © 2015 Aayush Kapoor. All rights reserved.
//

import UIKit
import AVFoundation
import CoreImage

class ViewController: UIViewController {
    
    var captureSessionIsRunning: Bool?
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var detector: CIDetector?
    var image: UIImage?
    
    @IBOutlet weak var capturedImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        
    }
    
    override func viewDidAppear(animated: Bool) {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = AVCaptureSessionPresetPhoto
        
        var frontCamera: AVCaptureDevice! = nil
        
        let videoDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        
        for device in videoDevices{
            let device = device as! AVCaptureDevice
            if device.position == AVCaptureDevicePosition.Front {
                frontCamera = device
                break
            }
        }
        
        let input = try! AVCaptureDeviceInput(device: frontCamera)
        
        if (captureSession?.canAddInput(input) != nil) {
            captureSession?.addInput(input)
        }
        
        stillImageOutput = AVCaptureStillImageOutput()
        
        stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        
        captureSession?.addOutput(stillImageOutput)
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        capturedImage.layer.addSublayer(previewLayer!)
        previewLayer?.frame = capturedImage.bounds
        
        captureSessionIsRunning = true
        captureSession?.startRunning()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didPressTakePhoto(sender: UIButton) {
        
        if captureSessionIsRunning == true {
            if let videoConnection = stillImageOutput?.connectionWithMediaType(AVMediaTypeVideo) {
                stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProviderCreateWithCFData(imageData)
                    let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                    self.image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
                    self.capturedImage.image = self.image
                })
            }
            captureSessionIsRunning = false
            captureSession?.stopRunning()
        } else if captureSessionIsRunning == false {
            captureSessionIsRunning = true
            captureSession?.startRunning()
        }
    }
    
    @IBAction func didPressGoogleEyes(sender: UIButton) {
        
        let ciimage = CIImage(image: image!)
        let features = detector?.featuresInImage(ciimage!)
        print(features?.count)
        for feature in features as! [CIFaceFeature] {
            print(feature.leftEyePosition, feature.rightEyePosition)
            GooglyEyes(leftEye: feature.leftEyePosition, rightEye: feature.rightEyePosition, image: image!)
        }
        
    }
    
    func GooglyEyes(leftEye leftEye: CGPoint, rightEye: CGPoint, image: UIImage) {
        let x: CGFloat = 100
        let eye = UIImage(named: "eye")
        UIGraphicsBeginImageContext(image.size)
        image.drawInRect(CGRectMake(0, 0, image.size.width, image.size.height))
        eye?.drawInRect(CGRectMake(leftEye.x - x/2, leftEye.y - x/2, x, x))
        eye?.drawInRect(CGRectMake(rightEye.x - x/2, rightEye.y - x/2, x, x))
        self.capturedImage.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
}
