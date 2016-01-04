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
  
  
  @objc override init() {
    
    super.init()
  }
  
  @objc public func setTestURL(url: NSURL) {
    
    self.resetDatas()
    self.parseURL(url)
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
  
  private func launchSendingTimer() {
    
    self.timer = NSTimer.scheduledTimerWithTimeInterval(timerDuration, target: self, selector: "sendDatas", userInfo: nil, repeats: false)
  }
  
  private func createJSONObject() -> [String : AnyObject] {
    
    return ["id" : self.idTest!,
      "url" : url!,
      "result" : self.createResultObject()]
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
      }
    }
  }
}