//
//  ViewController.swift
//  Deep Sense
//
//  Created by Fabian Vergara on 2016-10-21.
//  Copyright © 2016 fvergara. All rights reserved.
//

import UIKit
import AVFoundation

var emotionData = [String]()

class ViewController: UIViewController, UIImagePickerControllerDelegate {

    @IBOutlet var picture: UIImageView!
    @IBOutlet var cameraView: UIView!
    
    var captureSession: AVCaptureSession?
    var stillImageOutput   : AVCaptureStillImageOutput?
    var previewLayer  : AVCaptureVideoPreviewLayer?
    
    let cognitiveServices = CognitiveServices.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        recognizePicture()
    }
    
    func recognizePicture(){
        let analyzeImage = CognitiveServices.sharedInstance.analyzeImage
        
        let visualFeatures: [AnalyzeImage.AnalyzeImageVisualFeatures] = [.Categories, .Description, .Faces, .ImageType, .Color, .Adult]
        let requestObject: AnalyzeImageRequestObject = ( picture.image!, visualFeatures)
        
        try! analyzeImage.analyzeImageWithRequestObject(requestObject, completion: { (response) in
            DispatchQueue.main.async(execute: {
              //  self.textView.text = response?.descriptionText
              //  print(response?.descriptionText)
               // print(response?.categories)
              //  print(response?.tags)
            })
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //previewLayer?.frame = cameraView.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     /*
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = AVCaptureSessionPreset1920x1080
        
        var backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        // var error : NSError?
        var input: AVCaptureDeviceInput?
        //   input = AVCaptureDeviceInput(device: backCamera) throws ->
        
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
            captureSession?.addInput(input)
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput?.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
            
            if (captureSession?.canAddOutput(stillImageOutput) != nil ){
                captureSession?.addOutput(stillImageOutput)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer?.videoGravity = AVLayerVideoGravityResizeAspect
                previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.portrait
                cameraView.layer.addSublayer(previewLayer!)
                captureSession?.startRunning()
            }
            
            //  var input = AVCaptureDeviceInput(device: backCamera)
            
        } catch let error {
            print(error)
        }
        */
    }

}

