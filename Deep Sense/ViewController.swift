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

class ViewController: UIViewController, UIImagePickerControllerDelegate {

    @IBOutlet var picture: UIImageView!
    @IBOutlet var cameraView: UIView!
    
    var captureSession: AVCaptureSession?
    var stillImageOutput   : AVCaptureStillImageOutput?
    var previewLayer  : AVCaptureVideoPreviewLayer?
    
    let cognitiveServices = CognitiveServices.sharedInstance
    
    var timer : Timer?
    
    var midiPlayer:AVMIDIPlayer!
    
   // let socket = SocketIOClient(socketURL: URL(fileURLWithPath: "10.251.202.166:8000"))

    
   // let socket = SocketIOClient(socketURL: URL(string: "http://10.251.202.166:8080/")!, config: [.log(true), .forcePolling(true)])
    
   

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        timer = Timer.scheduledTimer(timeInterval: 7, target: self, selector: #selector(ViewController.getEmotions), userInfo: nil, repeats: false)
      
   /*     let midiFILEUrl = URL(string: "http://10.251.202.166:5000/song.mid")
        //URL("http://10.251.202.166:5000/song.mid")
        
        var downloadTask:URLSessionDownloadTask
        downloadTask = URLSession.shared.downloadTask(with: (midiFILEUrl)!, completionHandler: { (URL, response, error) -> Void in
            
            self.createAVMIDIPlayerFromMIDIFIleDLS(midiFILEUrl: URL!)
            
        })*/
        
        //downloadTask.resume()
        
        createAVMIDIPlayerFromMIDIFIleDLS()

        recognizePicture()
        
        play()
        
        
       // let url = URL(fileURLWithPath: "http://10.251.202.166:5000/dad/FabianAndWaitAgain/1")
      
        Alamofire.request("http://10.251.202.166:5000/dad/Tree/2").response { response in
            print("Request: \(response.request)")
            print("Response: \(response.response)")
            print("Error: \(response.error)")
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)")
            }
        }
        

   /*     Alamofire.request(url).responseJSON { response in
            print(response.request)  // original URL request
            print(response.response) // HTTP URL response
            print(response.data)     // server data
            print(response.result)   // result of response serialization
            
            if let JSON = response.result.value {
                print("JSON: \(JSON)")
            }
        }*/
        
        
        
        
       // self.addHandlers()
        
       // socket.emitTest(event: "test", data: Any...)
      /*  self.socket.connect()
        
        socket.on("connect") {data, ack in
            print("socket connected")
            self.socket.emit("test", "hello")
        }
        
        //self.socket.didConnect()
        
        self.socket.emit("test", "hello there")*/

    }
    
    func addHandlers() {
        // Our socket handlers go here
        // Using a shorthand parameter name for closures
        //self.socket.emit

      //  self.socket.emit("test", "sdfdsfsfs")
     //   print("sent")
        
        
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

