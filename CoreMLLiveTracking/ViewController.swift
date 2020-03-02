//
//  ViewController.swift
//  CoreMLLiveTracking
//
//  Created by Apple on 02/03/2020.
//  Copyright © 2020 Apple. All rights reserved.
//


import UIKit
import AVKit
import Vision


class ViewController: UIViewController,AVCaptureVideoDataOutputSampleBufferDelegate{
    
    var label:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.label = UILabel(frame: CGRect(x: self.view.frame.width/3, y: self.view.frame.height * 0.9 , width: 300, height: 100))
//        self.label.backgroundColor = .black
        self.label.textColor = .black
        
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {return}
        let input = try! AVCaptureDeviceInput(device: captureDevice)
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        //        label = UILabel(frame: CGRect(x: self.view.frame.width/2, y: self.view.frame.height * 0.9 , width: 100, height: 100))
        //
        
        //        let request = VNCoreMLRequest(model)
        //        VNImageRequestHandler(cgImage: <#T##CGImage#>, options: <#T##[VNImageOption : Any]#>)
        
               self.view.addSubview(label)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer:CVPixelBuffer =  CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        
        let model = try? VNCoreMLModel(for: Resnet50().model)
        
        let request = VNCoreMLRequest(model: model!) { (Response, Error) in
            
            let results = Response.results as? [VNClassificationObservation]
            
            let firstObservation = results?.first
            
            print(firstObservation?.identifier,firstObservation?.confidence)
            
            DispatchQueue.main.async {
                
                self.label.text = firstObservation?.identifier
          
            }
       
        }
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer,options: [:]).perform([request])
        
        print("Camera was able to capture a frame",Date())
    }
    
}

