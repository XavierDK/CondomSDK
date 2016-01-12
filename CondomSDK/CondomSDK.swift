/*
* Copyright (C) PagesJaunes, SoLocal Group - All Rights Reserved.
*
* Unauthorized copying of this file, via any medium is strictly prohibited.
* Proprietary and confidential.
*/

import Foundation
import UIKit

@objc public class CondomSDK: NSObject {
  
  @objc public static let sharedInstance: CondomSDK = CondomSDK()
  
  public static let NONE_SUBKEY = "NONE"
  
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
  private var ciMobKitUrl: String?
  private var gps: String?
  
  private let topScreenNameKey = "topScreenName"
  
  
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
  
  @objc public func expectedKeysForSubKey(subKey: String) -> Array<String> {
    
    var expectedKeys: [String] = [String]()
    
    if subKey == CondomSDK.NONE_SUBKEY {
      for key in self.expectedKeys {
        
        if key.containsString(".") == false {
          expectedKeys.append(key)
        }
      }
    }
      
    else {
      for key in self.expectedKeys {
        
        if key.containsString(subKey + ".") {
          var keyTmp = key
          keyTmp.removeRange(keyTmp.rangeOfString(subKey + ".")!)
          expectedKeys.append(keyTmp)
        }
      }
    }
    
    return expectedKeys
  }
  
  private func checkExpectedKeys() -> Bool {
    
    for key in expectedKeys {
      if datas[key] == nil && key != self.topScreenNameKey {
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
      
      if let gps = params["gps"] {
        self.gps = gps
        
        NSUserDefaults.standardUserDefaults().setValue(self.gps, forKey: "gps")
      }
      
      if let ciMobKitUrl = params["ciMobKitUrl"] {
        self.ciMobKitUrl = ciMobKitUrl
        
        NSUserDefaults.standardUserDefaults().setValue(self.ciMobKitUrl, forKey: "server")
      }
      
      NSUserDefaults.standardUserDefaults().synchronize()
      
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
      
      if self.expectedKeys.count == 1 && self.expectedKeys.contains(self.topScreenNameKey) {
        self.launchSendingTimer()
      }
    }
  }
  
  private func launchTimeout() {
    
    if let timeout = self.timeout {
        
        NSTimer.scheduledTimerWithTimeInterval(timeout, target: self, selector: "sendDatas", userInfo: nil, repeats: false)
    }
  }
  
  private func launchSendingTimer() {
    
    self.timer = NSTimer.scheduledTimerWithTimeInterval(timerDuration, target: self, selector: "sendDatas", userInfo: nil, repeats: false)
  }
  
  private func killAppNow() {

    if self.killApp == true {
      
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        exit(EXIT_SUCCESS);
      });
    }
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
      else {
        res[key] = ""
      }
      
    }
    return res
  }
  
  func sendDatas() {
    
    if self.expectedKeys.contains(self.topScreenNameKey) {
      
      let topController : UIViewController? = self.topMostController()
      if let topController = topController {
        datas[self.topScreenNameKey] = NSStringFromClass(topController.dynamicType)
      }
    }
    
    if let url = serverUrl {
      let req = NSMutableURLRequest(URL: url)
      req.HTTPMethod = "POST"
      req.setValue("application/json", forHTTPHeaderField: "Content-Type")
      
      let jsonObject = self.createJSONObject()
      
      do {
        req.HTTPBody = try NSJSONSerialization.dataWithJSONObject(jsonObject, options: [])
      }
      catch {
      }
      
      request(req)
        .responseJSON { response in
          
          switch response.result {
          case .Success(_):
            self.killAppNow()
            
          case .Failure(let error):
            print("Request failed with error: \(error)")
            self.killAppNow()
          }
      }
    }
  }
  
  private func captureScreen() -> UIImage? {
    
    var window: UIWindow? = UIApplication.sharedApplication().keyWindow
    window = UIApplication.sharedApplication().windows.first
    UIGraphicsBeginImageContextWithOptions(window!.frame.size, window!.opaque, 0.0)
    window!.layer.renderInContext(UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image;
  }
  
  private func topMostController() -> UIViewController?
  {
    var topController = UIApplication.sharedApplication().keyWindow?.rootViewController;
    
    if let nvc = topController as? UINavigationController {
      topController = nvc.viewControllers.last
    }
    while (topController?.presentedViewController != nil) {
      topController = topController?.presentedViewController
    }
    return topController;
  }
}