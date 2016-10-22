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
    
    var timer : Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        timer = Timer.scheduledTimer(timeInterval: 7, target: self, selector: #selector(ViewController.getEmotions), userInfo: nil, repeats: false)
      

        recognizePicture()
    }
    /*
    func createAVMIDIPlayerFromMIDIFIleDLS() {
        
        guard let midiFileURL = Bundle.main.url(forResource: "john", withExtension: "mid") else {
            fatalError("\"john.mid\" file not found.")
        }
        
        guard let bankURL = Bundle.main.url(forResource: "Fury", withExtension: "dls") else {
            fatalError("\"gs_instruments.dls\" file not found.")
        }
        
        do {
            try self.midiPlayer = AVMIDIPlayer(contentsOfURL: midiFileURL, soundBankURL: bankURL)
            print("created midi player with sound bank url \(bankURL)")
        } catch let error as NSError {
            print("Error \(error.localizedDescription)")
        }
        
        self.midiPlayer.prepareToPlay()
    }*/
    
    func getEmotions(){
        for i in 0..<emotionData.count{
            print(emotionData[i])
        }

    }
    func recognizePicture(){
        let analyzeImage = CognitiveServices.sharedInstance.analyzeImage
        
        let visualFeatures: [AnalyzeImage.AnalyzeImageVisualFeatures] = [.Categories, .Description, .Faces, .ImageType, .Color, .Adult]
        let requestObject: AnalyzeImageRequestObject = ( picture.image!, visualFeatures)
        
        try! analyzeImage.analyzeImageWithRequestObject(requestObject, completion: { (response) in
            print("before cat")
           // print(response.)
            print("after cat")
            DispatchQueue.main.async(execute: {
                //self.textView.text = response?.descriptionText
                
                print(response?.categories)


 


            })
        })
        
       // print(emotionData[0])
    }
    
    func getRidOfRepeatedEmotions() -> Array<String>{
        var noRepEmotions = [String]()
        //var counter = 0
        for i in 0..<emotionData.count{
            for k in 0..<emotionData.count{
                if emotionData[i] == emotionData[k]{
                    noRepEmotions.append(emotionData[i])
                    break;
                }else if k == emotionData.count - 1{
                    noRepEmotions.append(emotionData[i])
                }
            }
            
        }
        
        return noRepEmotions
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

