//
//  ViewController.swift
//  QRReaderDemo
//
//  Created by Simon Ng on 23/11/14.
//  Copyright (c) 2014 AppCoda. All rights reserved.
//


import UIKit
import AVFoundation
import SwiftyJSON
class SeatTokenQRCodeReaderViewController: QRCodeReaderViewController {
    
    var completionHandler: ResponseHandler?
    override func verifyQRCode(code: String){
        self.captureSession?.stopRunning()
        self.showHudWithText("正在验证")
        let seatHelper = StudentSeatHelper.defaultHelper
        seatHelper.getSeatToken(code){
            [unowned self]
            error, json in
            if let error = error{
                self.hideHud()
                if error == CError.BAD_QR_CODE{
                    let alert = UIAlertController(title: nil, message: "无效的二维码！", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: {[unowned self]_ in self.captureSession?.startRunning()}))
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                }
                else{
                    
                    self.completionHandler?(error: error, json: json)
                    self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                }
            }
            else{
                self.hideHud()
                self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
}
