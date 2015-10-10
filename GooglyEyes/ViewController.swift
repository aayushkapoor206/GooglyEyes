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
    
    @IBOutlet weak var previewView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    
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
        previewView.layer.addSublayer(previewLayer!)
        previewLayer?.frame = previewView.bounds
        
        captureSessionIsRunning = true
        captureSession?.startRunning()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didPressTakePhoto(sender: UIButton) {
        var image: UIImage?
        if captureSessionIsRunning == true {
            if let videoConnection = stillImageOutput?.connectionWithMediaType(AVMediaTypeVideo) {
                stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProviderCreateWithCFData(imageData)
                    let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                    image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
                })
            }

            captureSession?.stopRunning()
            captureSessionIsRunning = false
            
            imageView.image = image
            imageView.hidden = false
            
            previewView.hidden = true
            
        } else if captureSessionIsRunning == false {
            
            captureSession?.startRunning()
            captureSessionIsRunning = true
            
            imageView.hidden = true
            
            previewView.hidden = false
        }
    }
    
    @IBAction func didPressGooglyEyes(sender: UIButton) {
        
        let img = imageView.image
        let ciimg = CIImage(image: img!)
        
        UIGraphicsBeginImageContextWithOptions(img!.size, true, 0)
        
        img!.drawInRect(CGRectMake(0, 0, img!.size.width, img!.size.height))
        
        let features = detector?.featuresInImage(ciimg!)
        for feature in features as! [CIFaceFeature] {
            
            let eye = UIImage(named: "eye")
            
            eye?.drawInRect(CGRectMake(feature.leftEyePosition.x, feature.leftEyePosition.y, 50, 50))
            eye?.drawInRect(CGRectMake(feature.rightEyePosition.x, feature.rightEyePosition.y, 50, 50))

        }
        
        let imgpro = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        imageView.image = imgpro
        
    }
}
