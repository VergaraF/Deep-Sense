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



import UIKit

extension String {
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}

extension Collection where Iterator.Element == UInt8 {
    
    var data: Data { return Data(bytes: Array(self)) }
    
    var string: String { return String(data: data, encoding: .utf8) ?? "" }
}

extension String.UTF8View {
    
    var array: [UInt8] { return Array(self) }
    
}

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
    @IBOutlet var shakespeare: UIButton!
    @IBOutlet var eliot: UIButton!
    @IBOutlet var frost: UIButton!
    @IBOutlet var prevImg: UIImageView!
    var poemLabel = UILabel()
    let movieFileOutput = AVCaptureMovieFileOutput()
    let movieDataOutput = AVCaptureVideoDataOutput()
    var oneTap = UITapGestureRecognizer()
    //var doubleTap = UITapGestureRecognizer()
    let cognitiveServices = CognitiveServices.sharedInstance
    
    @IBOutlet var authorsView: UIView!
    var timer : Timer?
    
    var midiPlayer:AVMIDIPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()

        addVideoCamera()
        addParallaxToView(vw: shakespeare)
        addParallaxToView(vw: eliot)
        addParallaxToView(vw: frost)
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


        //createAVMIDIPlayerFromMIDIFIleDLS()

        
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
        UIView.animate(withDuration: 0.4, animations: {
            self.authorsView.alpha = 1
            self.prevView.alpha = 1
        })
        
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
            emotionData.removeAll()
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
                        UIView.animate(withDuration: 0.4, animations: {
                            self.authorsView.alpha = 1
                            self.prevView.alpha = 1
                        })
                        let pulseAni = CABasicAnimation(keyPath: "transform.scale")
                        pulseAni.duration = 0.6
                        pulseAni.fromValue = 0
                        pulseAni.toValue = 1.0
                        pulseAni.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                        pulseAni.autoreverses = false
                        pulseAni.repeatCount = 0
                        self.shakespeare.layer.add(pulseAni, forKey: nil)
                        self.frost.layer.add(pulseAni, forKey: nil)
                        self.eliot.layer.add(pulseAni, forKey: nil)
                        self.loopImg()
                    }
                    //UIImageWriteToSavedPhotosAlbum(UIImage(data: imageData!)!, nil, nil, nil)
                }


            }
        }
        }


    }
    
    @IBAction func authorsClicked(_ sender: AnyObject) {
        UIView.animate(withDuration: 0.4, animations: {
            Alamofire.request("http://10.251.202.68:5000/dad/\(emotionData[0])/\(sender.tag!)").response { response in
                print("Request: \(response.request)")
                print("Response: \(response.response)")
                print("Error: \(response.error)")
                
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    let finalPoem = utf8Text.replacingOccurrences(of: "/\n", with: "")
                    self.poemLabel.lineBreakMode = NSLineBreakMode.byCharWrapping
                    self.poemLabel.text = "\(finalPoem)"
                    print("Data: \(utf8Text)")
                }
            }
            self.authorsView.alpha = 0
        })
    }
    
    func addParallaxToView(vw: UIView) {
        let amount = 100
        
        let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontal.minimumRelativeValue = -amount
        horizontal.maximumRelativeValue = amount
        
        let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        vertical.minimumRelativeValue = -amount
        vertical.maximumRelativeValue = amount
        
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontal, vertical]
        vw.addMotionEffect(group)
    }
    
    func loopImg(){
        oneTap.isEnabled = false
        let finalTXT = newEncoded.fromBase64()
        
        print("NEW DATA: \(finalTXT?.fromBase64())")
        prevImg.image = UIImage(data: imagesArray[0])!
        prevImg.animationImages = [UIImage(data: imagesArray[0])!, UIImage(data: imagesArray[1])!, UIImage(data: imagesArray[2])!, UIImage(data: imagesArray[3])!, UIImage(data: imagesArray[4])!, UIImage(data: imagesArray[5])!, UIImage(data: imagesArray[6])!, UIImage(data: imagesArray[7])!, UIImage(data: imagesArray[8])!, UIImage(data: imagesArray[9])!]
        prevImg.animationDuration = 0.5
        prevImg.startAnimating();
        //UIImage(data: imageData!)!
        timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(ViewController.getEmotions), userInfo: nil, repeats: false)

        recognizePicture()

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

    var newEncoded = ""
    func createAVMIDIPlayerFromMIDIFIleDLS() {
        
        Alamofire.request("http://10.251.194.99:5000/midi/1").response { response in
            print("request: \(response.request)")
            print("response: \(response.response)")
            print("errors: \(response.error)")
            if let data = response.data, let utf8Text = String(data: data, encoding: String.Encoding.utf8) {
                //stringByReplacingPercentEscapesUsingEncoding(String.Encoding.utf8)!
           //     let bytes = utf8Text.utf8.array
               // let result = bytes.string
                let finalTxt = utf8Text.replacingOccurrences(of: "\"", with: "")
                print("FINAL TEXT:\(finalTxt)")
                let decoded = NSData(base64Encoded: "\(finalTxt)", options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
                guard let bankURL = Bundle.main.url(forResource: "gs_instruments", withExtension: "dls") else {
                    fatalError("\"gs_instruments.dls\" file not found.")
                }
                do{
                    try self.midiPlayer = AVMIDIPlayer(data: decoded as! Data, soundBankURL: bankURL)
                    print("created midi player with sound bank url \(bankURL)")
                } catch let error as NSError {
                    print("Error \(error.localizedDescription)")
                }
                self.midiPlayer.prepareToPlay()
                self.play()
                //properString = result

            }
//            if let data = response.data{
//                var stringData = String(describing: response.data) + ""
//                print(stringData)
//            }
            
        }


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
        emotionData = getRidOfRepeatedEmotions()
        for i in 0..<emotionData.count{
            print(emotionData[i])
        }

    }
    func recognizePicture(){
        let analyzeImage = CognitiveServices.sharedInstance.analyzeImage
        
        let visualFeatures: [AnalyzeImage.AnalyzeImageVisualFeatures] = [.Categories, .Description, .Faces, .ImageType, .Color, .Adult]
        let requestObject: AnalyzeImageRequestObject = ( UIImage(data: imagesArray[0]), visualFeatures)
        
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
                if emotionData[i] == emotionData[k] && k != i{
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
    //createAVMIDIPlayerFromMIDIFIleDLS()
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

 

    }



