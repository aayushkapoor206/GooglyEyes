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
    
    @IBOutlet weak var capturedImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh, CIDetectorSmile: true])
        
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
                    let image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
                    self.capturedImage.image = image
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
        
        let image = CIImage(image: self.capturedImage.image!)
        let features = detector?.featuresInImage(image!, options: [CIDetectorSmile : true, CIDetectorEyeBlink : true])

        for feature in features as! [CIFaceFeature] {
            print(feature)
        }
        
    }
    
}
