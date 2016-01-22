//
//  ARKView.swift
//  ArkCamera
//
//  Created by xuan on 16/1/22.
//  Copyright © 2016年 xuan. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary

@objc protocol ARKViewDelegate{
    
    optional func deviceConfigurationFailedWhithError()
    
    optional func mediaCaptureFailedWhithErroe()
    
    optional func assetLibraryWriteFailedWhithError()
    
    optional func getImg(imgdata:NSData,imgUrl:NSURL)
    
    optional func getVideo(url:NSURL)
    
    optional func error(code:String)
    
}

class ARKView: UIView{
    //会话
    var session:AVCaptureSession?
    //图像输入
    var cameraInput:AVCaptureDeviceInput?
    //图片输出
    var imgOutput:AVCaptureStillImageOutput?
    //视频输出
    var videoOutput:AVCaptureMovieFileOutput?
    //图片输出地址
    var imgURL:NSURL!
    //视频输出地址
    var videoURL:NSURL?
    //执行线程
    lazy var videoqueue:dispatch_queue_t = {
        dispatch_queue_create("com.arick.ARKView", nil)
    }()
    //预览层
    var videoLayer: AVCaptureVideoPreviewLayer?
    
    //调整曝光
    var ARKCameraAdjustingExposureContext:String = "THCameraAdjustingExposureContext"
    
    var delegate:ARKViewDelegate!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setSession()
        setVideoLayer()
        startsession()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSession(){
        //创见会话
        session = AVCaptureSession()
        //默认输入设备
        let cameraDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        do{
            cameraInput =
            try AVCaptureDeviceInput(device: cameraDevice)
        }catch{
            self.delegate.error!("没有相机设备")
        }
        
        
        //把输入连接到会话
        if (cameraInput != nil){
            session?.addInput(cameraInput)
        }else{
            self.delegate.error!("相机没有工作")
        }
        
        //默认麦克风
        let audioDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
        
        //把声音输入连接到会话
        if let audioinput = try? AVCaptureDeviceInput(device: audioDevice){
            session?.addInput(audioinput)
        }else{
            self.delegate.error!("声音设备没有工作")
        }
        
        //图片输出
        imgOutput = AVCaptureStillImageOutput()
        //输出类型
        imgOutput?.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
        
        if (session?.canAddOutput(imgOutput) != nil){
            session?.addOutput(imgOutput)
        }
        
        //视频输出
        videoOutput = AVCaptureMovieFileOutput()
        
        if (session?.canAddOutput(videoOutput) != nil){
            session?.addOutput(videoOutput)
        }
        
        //设置质量
        if session!.canSetSessionPreset(AVCaptureSessionPresetPhoto){
            session?.sessionPreset = AVCaptureSessionPresetPhoto
        }
        
        
    }
    
    //设置图像质量
    func setPreset(Preset:String){
        if session!.canSetSessionPreset(Preset){
            session!.sessionPreset = Preset
        }
    }
    
    func setVideoLayer(){
        //创建预览层
        videoLayer = AVCaptureVideoPreviewLayer(session: session)
        //填充模式
        videoLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        //预览层的方向
        videoLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
        //预览层的frame
        videoLayer?.frame = self.bounds
        
        videoLayer?.masksToBounds = true
        
        self.layer.addSublayer(videoLayer!)
    }
    
    
    
    func startsession(){
        
        if (session?.running == false){
            print("没有运行")
            dispatch_async(videoqueue, { () -> Void in
                self.session?.startRunning()
                print("开始运行")
            })
            
        }
        
        
    }
    
    func stopsession(){
        if (session?.running != false){
            dispatch_async(videoqueue, { () -> Void in
                self.session?.stopRunning()
            })
            
        }
    }
}

extension ARKView:AVCaptureMetadataOutputObjectsDelegate{
    
}

extension ARKView:AVCaptureFileOutputRecordingDelegate{
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!){
        
    }
}

