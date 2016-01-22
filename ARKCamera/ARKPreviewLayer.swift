//
//  ARKPreviewLayer.swift
//  ArkCamera
//
//  Created by xuan on 16/1/22.
//  Copyright © 2016年 xuan. All rights reserved.
//

import UIKit
import AVFoundation

class ARKPreviewLayer:AVCaptureVideoPreviewLayer{
    
    
    override init!(session: AVCaptureSession!){
        super.init(session: session)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setLayer(){
        //填充模式
        self.videoGravity = AVLayerVideoGravityResizeAspectFill
        //预览层的方向
        self.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
        self.masksToBounds = true
    }
    
    //预览层的方向
    func setNewOrientation(Orientation:AVCaptureVideoOrientation){
        self.connection?.videoOrientation = Orientation
    }
    
}
