//
//  CondomSDK.swift
//  CondomSDK
//
//  Created by Xavier De Koninck on 22/12/2015.
//  Copyright © 2015 PagesJaunes. All rights reserved.
//

import Foundation
import Alamofire

@objc public class CondomSDK: NSObject {
  
  @objc public static let sharedInstance: CondomSDK = CondomSDK()
  
  private let timerDuration : NSTimeInterval = 10
  
  private lazy var datas: [String: String] = [String: String]()
  private var timer: NSTimer?
  
  private var testingEnable: Bool = false
  private var idTest: String?
  private var url: NSURL?
  private var serverUrl: NSURL?
  private lazy var expectedKeys: [String] = [String]()
  private var killApp: Bool = false
  private var screenshot: Bool = false
  private var timeout: NSTimeInterval?
  
  
  @objc override init() {
    
    super.init()
  }
  
  @objc public func setTestURL(url: NSURL) {
    
    self.resetDatas()
    self.url = url
    self.parseURL(url)
    self.launchTimeout()
  }
  
  @objc public func resetDatas() {
    
    self.datas.removeAll()
    self.testingEnable = false
    self.idTest = nil
    self.serverUrl = nil
    self.expectedKeys = [String]()
    self.killApp = false
    self.screenshot = false
  }
  
  @objc public func setTestValue(value: String, forKey key: String) {
    
    if self.testingEnable == true {
      if timer != nil {
        timer?.invalidate()
        timer = nil
      }
      
      datas[key] = value
      
      if self.checkExpectedKeys() == true {
        self.launchSendingTimer()
      }
    }
  }
  
  private func checkExpectedKeys() -> Bool {
    
    for key in expectedKeys {
      if datas[key] == nil {
        return false
      }
    }
    return true
  }
  
  private func parseURL(url: NSURL) {
    
    let params = url.getKeyVals()
    
    if let params = params {
      if params["debug"] != nil {
        testingEnable = true
      }
      if params["killApp"] != nil {
        killApp = true
      }
      if params["screenshot"] != nil {
        screenshot = true
      }
      if let timeout = params["timeout"] {
        self.timeout = Double(timeout)
      }

      if let serverUrl = params["serverUrl"] {
        self.serverUrl = NSURL(string: serverUrl)
      }
      if let idTest = params["idTest"] {
        self.idTest = idTest
      }
      if let paramsList = params["paramsList"] {
        let expectedParams = paramsList.componentsSeparatedByString(",")
        self.expectedKeys = expectedParams
      }
    }
  }
  
  private func launchTimeout() {
    
    if killApp == true,
       let timeout = self.timeout {
      
      NSTimer.scheduledTimerWithTimeInterval(timeout, target: self, selector: "killAppNow", userInfo: nil, repeats: false)
    }
  }
  
  private func launchSendingTimer() {
    
    self.timer = NSTimer.scheduledTimerWithTimeInterval(timerDuration, target: self, selector: "sendDatas", userInfo: nil, repeats: false)
  }
  
  private func killAppNow() {
    exit(EXIT_SUCCESS)
  }
  
  private func createJSONObject() -> [String : AnyObject] {
    
    var res: [String: AnyObject] = ["id" : self.idTest!,
      "url" : "\(url!)",
      "result" : self.createResultObject()]
    
    if self.screenshot == true {
      
      let image = self.captureScreen()
      let imageData = UIImagePNGRepresentation(image!)
      let base64String = imageData!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
      res["screenshot"] = base64String
    }
    
    return res
  }
  
  private func createResultObject() -> [String: String] {
    
    var res = [String: String]()
    for key in self.expectedKeys {
      if let data = self.datas[key] {
        res[key] = data
      }
    }
    return res
  }
  
  func sendDatas() {
    
    if let url = serverUrl {
      let request = NSMutableURLRequest(URL: url)
      request.HTTPMethod = "POST"
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      
      let jsonObject = self.createJSONObject()
      
      do {
        request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(jsonObject, options: [])
      }
      catch {
      }
      
      Alamofire.request(request)
        .responseJSON { response in
          
          switch response.result {
          case .Success(let JSON):
            print("Success with JSON: \(JSON)")
            
            if JSON["status"] as? String == "success" {
              
              if self.killApp == true {
                self.killAppNow()
              }
            }
            
          case .Failure(let error):
            print("Request failed with error: \(error)")
          }
      }
    }
  }
  
  private func captureScreen() -> UIImage? {
    
    var window: UIWindow? = UIApplication.sharedApplication().keyWindow
    window = UIApplication.sharedApplication().windows[0]
    UIGraphicsBeginImageContextWithOptions(window!.frame.size, window!.opaque, 0.0)
    window!.layer.renderInContext(UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image;
  }
}