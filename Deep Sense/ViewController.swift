//
//  ViewController.swift
//  Deep Sense
//
//  Created by Fabian Vergara on 2016-10-21.
//  Copyright © 2016 fvergara. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire




var emotionData = [String]()

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var cameraView: UIView!
    @IBOutlet var flipBtn: UIButton!
    @IBOutlet var galleryBtn: UIButton!
    var imagesArray: [Data]! = []
    let stillImageOutput = AVCaptureStillImageOutput()
    var captureSession: AVCaptureSession! = nil
    var captureLayer: AVCaptureVideoPreviewLayer! = nil
    
    @IBOutlet var scrollBtn: UIScrollView!
    var cameraDeviceInput: AVCaptureDeviceInput! = nil
    var cameraFrontDeviceInput: AVCaptureDeviceInput! = nil
    var activeDeviceInput:AVCaptureDeviceInput! = nil
    let imagePicker = UIImagePickerController()
    var takePic = true
    @IBOutlet var poemScroll: UIScrollView!
    @IBOutlet var prevView: UIView!
    @IBOutlet var prevImg: UIImageView!
    var poemLabel = UILabel()
    let movieFileOutput = AVCaptureMovieFileOutput()
    let movieDataOutput = AVCaptureVideoDataOutput()
    var oneTap = UITapGestureRecognizer()
    //var doubleTap = UITapGestureRecognizer()
    let cognitiveServices = CognitiveServices.sharedInstance
    
    var timer : Timer?
    
    var midiPlayer:AVMIDIPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
 		timer = Timer.scheduledTimer(timeInterval: 7, target: self, selector: #selector(ViewController.getEmotions), userInfo: nil, repeats: false)
        addVideoCamera()
        poemLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2, y: self.view.frame.size.height, width: self.view.frame.size.width, height: self.view.frame.size.height))
        poemLabel.center = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height*1.5)
        poemScroll.isPagingEnabled = true
        poemScroll.showsVerticalScrollIndicator = false
        poemLabel.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        poemLabel.font = UIFont(name: "Avenir-Medium", size: 16)
        poemLabel.textColor = .white
        poemLabel.shadowColor = .black
        poemLabel.shadowOffset = CGSize(width: 0, height: 2)
        poemLabel.layer.shadowOpacity = 0.4
        poemLabel.textAlignment = .center
        poemLabel.numberOfLines = 25
        poemLabel.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi eu ultricies nulla. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Suspendisse rutrum quam ac est dignissim condimentum. Nullam consectetur dictum leo sit amet lacinia. Nulla suscipit tincidunt elementum. Maecenas erat orci, vehicula in risus id, hendrerit pulvinar libero. Aenean aliquam dignissim metus, sed ultrices mi egestas eget. Praesent hendrerit metus nunc. In vulputate sem sit amet nunc auctor cursus. Duis aliquam erat at euismod commodo. Donec a metus finibus, varius ante quis, vulputate arcu. Mauris finibus, justo sit amet finibus consequat, dui felis iaculis arcu, et luctus sapien magna tristique nunc. Etiam accumsan, felis ac sagittis venenatis, metus leo gravida turpis, nec elementum odio quam a quam. Maecenas viverra nulla eget malesuada eleifend."
        poemScroll.addSubview(poemLabel)
        poemScroll.contentSize = CGSize(width: 0, height: self.view.frame.size.height*2)
        oneTap = UITapGestureRecognizer(target: self, action: #selector(ViewController.takeApic))
        oneTap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(oneTap)
        
        //doubleTap = UITapGestureRecognizer(target: self, action: #selector(ViewController.flipit))
        //doubleTap.numberOfTapsRequired = 2
        //self.view.addGestureRecognizer(doubleTap)


        createAVMIDIPlayerFromMIDIFIleDLS()

        recognizePicture()
        
        play()
    }

    
    @IBAction func galleryBtn(_ sender: AnyObject) {
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        //imagePicker.mediaTypes = [kUTTypeImage as NSString]
        imagePicker.mediaTypes = ["public.image"]
        imagePicker.allowsEditing = false
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func scrollIt(_ sender: AnyObject) {
        UIView.animate(withDuration: 0.4, animations: {
                    self.poemScroll.contentOffset = CGPoint(x: 0, y: self.poemScroll.frame.size.height)
        })
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("image selected")
        let img = info[UIImagePickerControllerOriginalImage] as? UIImage
        print(img)
        oneTap.isEnabled = false
        prevImg.image = img
        prevView.alpha = 1
        imagePicker.dismiss(animated: true, completion: nil)
    }
    @IBAction func closeImage(_ sender: AnyObject) {
        poemScroll.contentOffset = CGPoint(x:0,y:0);
        captureSession.startRunning()
        takePic = true
        flipBtn.isEnabled = true
        galleryBtn.isEnabled = true
        UIView.animate(withDuration: 0.4, animations: {
            self.prevView.alpha = 0
            self.prevImg.stopAnimating()
            self.prevImg.image = nil
            self.oneTap.isEnabled = true
        })
    }
    
    @IBAction func flipCam(_ sender: AnyObject) {
        flipit()
    }
    
    func takeApic(){
        if takePic {
            flipBtn.isEnabled = false
            galleryBtn.isEnabled = false
            takePic = false
        imagesArray.removeAll()
        for i in 0 ..< 10 {
            if let videoConnection = stillImageOutput.connection(withMediaType: AVMediaTypeVideo) {
                stillImageOutput.captureStillImageAsynchronously(from: videoConnection) {
                    (imageDataSampleBuffer, error) -> Void in
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                    self.imagesArray.append(imageData!)
                    UIView.animate(withDuration: 0.4, animations: {
                        self.prevView.alpha = 1
                    })
                    if i == 9 {
                        self.loopImg()
                    }
                    //UIImageWriteToSavedPhotosAlbum(UIImage(data: imageData!)!, nil, nil, nil)
                }


            }
        }
        }

    }
    
    func loopImg(){
        oneTap.isEnabled = false
        
        prevImg.image = UIImage(data: imagesArray[0])!
        prevImg.animationImages = [UIImage(data: imagesArray[0])!, UIImage(data: imagesArray[1])!, UIImage(data: imagesArray[2])!, UIImage(data: imagesArray[3])!, UIImage(data: imagesArray[4])!, UIImage(data: imagesArray[5])!, UIImage(data: imagesArray[6])!, UIImage(data: imagesArray[7])!, UIImage(data: imagesArray[8])!, UIImage(data: imagesArray[9])!]
        prevImg.animationDuration = 0.5
        prevImg.startAnimating();
        //UIImage(data: imageData!)!
    }
    
    func flipit(){
        print("flip camera")
        if captureSession.inputs[0] as! AVCaptureInput == cameraDeviceInput {
            // tapPlayer.play()
            // self.configureVideoWithDevice(self.cameraFrontDeviceInput.device)
            self.captureSession.removeInput(self.cameraDeviceInput)
            self.captureSession.addInput(self.cameraFrontDeviceInput)
            self.activeDeviceInput = self.cameraFrontDeviceInput
            NSLog("FRONT")
        } else {
            //tapPlayer.play()
            //self.configureVideoWithDevice(self.cameraDeviceInput.device)
            self.captureSession.removeInput(self.cameraFrontDeviceInput)
            self.captureSession.addInput(self.cameraDeviceInput)
            self.activeDeviceInput = self.cameraDeviceInput
            
            NSLog("BACK")
            
        }
    }

    
    func createAVMIDIPlayerFromMIDIFIleDLS() {
   /*     Alamofire.request("http://10.251.202.166:5000/song.mid").response { response in
            print("Request: \(response.request)")
            print("Response: \(response.response)")
            print("Error: \(response.error)")
            
            print(response.data)
            print("MIDI File")
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)")
                
                
            }
        }*/
        //Get midi online
        
        

        
    
        guard let midiFileURL = Bundle.main.url(forResource: "john", withExtension: "mid") else {
            fatalError("\"john.mid\" file not found.")
        }
        
        guard let bankURL = Bundle.main.url(forResource: "gs_instruments", withExtension: "dls") else {
            fatalError("\"gs_instruments.dls\" file not found.")
        }
        
        do {
            try self.midiPlayer = AVMIDIPlayer(contentsOf: midiFileURL, soundBankURL: bankURL)
            print("created midi player with sound bank url \(bankURL)")
        } catch let error as NSError {
            print("Error \(error.localizedDescription)")
        }
        
        self.midiPlayer.prepareToPlay()
    }
    
    func play() {
        //startTimer()
        self.midiPlayer.play({
            print("finished")
            self.midiPlayer.currentPosition = 0
           // self.timer?.invalidate()
        })
    }
    
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
        
   /*     self.socket.connect()
        
        self.socket.on("connect") {data, ack in
            print("socket connected")
            self.socket.emit("test", "hello")
            
            
        }
        
        socket.on("currentAmount") {data, ack in
            if let cur = data[0] as? Double {
                self.socket.emitWithAck("canUpdate", cur)(0) {data in
                    self.socket.emit("update", ["amount": cur + 2.50])
                }
                
                ack.with("Got your currentAmount", "dude")
            }
        }
        */

        
        
        //previewLayer?.frame = cameraView.bounds
        captureLayer?.frame = cameraView.bounds
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /*let backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)

        previewLayer?.frame = cameraView.bounds

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
                cameraView.layer.insertSublayer(previewLayer!, at: 0)
                cameraView.layer.addSublayer(previewLayer!)

                captureSession?.startRunning()
            }
            
            //  var input = AVCaptureDeviceInput(device: backCamera)
            
        } catch let error {
            print(error)

        }*/
        
    }
    func addVideoCamera() {
        //        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions: AVAudioSessionCategoryOptions.MixWithOthers)
        //        try! AVAudioSession.sharedInstance().setActive(true)
        
        captureSession = AVCaptureSession()
        captureSession.usesApplicationAudioSession = true
        captureSession.automaticallyConfiguresApplicationAudioSession = false
        
        let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
        for device in devices! {
            if (device as AnyObject).position == AVCaptureDevicePosition.front {
                do {
                    cameraFrontDeviceInput = try AVCaptureDeviceInput(device: device as! AVCaptureDevice)
                } catch _ {
                    
                }
            } else if (device as AnyObject).position == AVCaptureDevicePosition.back {
                do {
                    cameraDeviceInput = try AVCaptureDeviceInput(device: device as! AVCaptureDevice)
                } catch _ {
                    
                }
            }
        }
        
        
        
        if captureSession.canAddInput(cameraFrontDeviceInput) {
            captureSession.addInput(cameraFrontDeviceInput)
            activeDeviceInput = cameraFrontDeviceInput
        }
        
        if captureSession.canAddOutput(movieFileOutput) {
            captureSession.addOutput(movieFileOutput)
        }
        if captureSession.canAddOutput(movieDataOutput) {
            print("video data OUTPUT ADDED")
            //let cameraQueue = dispatch_queue_create("cameraQueue", dispatchMain())
            //movieDataOutput.setSampleBufferDelegate(self, queue: cameraQueue)
            captureSession.addOutput(movieDataOutput)
        }
        
        stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
        if captureSession.canAddOutput(stillImageOutput) {
            captureSession.addOutput(stillImageOutput)
        }
        
        captureSession.sessionPreset = AVCaptureSessionPreset1280x720
        captureSession.startRunning()
        
        captureLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        captureLayer.frame = view.frame
        view.layer.insertSublayer(captureLayer, at: 0)
        
        //        print(AVAudioSession.sharedInstance().category)
        //        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
        //        print(AVAudioSession.sharedInstance().category)

        }

        */

    }

}

