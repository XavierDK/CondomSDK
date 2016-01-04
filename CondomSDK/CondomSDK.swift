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
  private var keys: [String] = [String]()
  private var timer: NSTimer?
  
  private var idTest: String?
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
  }
  
  @objc public func setTestValue(value: String, forKey key: String) {
    
    if timer != nil {
      timer?.invalidate()
      timer = nil
    }
    
    datas[key] = value
    
    if self.checkExpectedKeys() {
      self.launchSendingTimer()
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
  
    //pagesjaunes://pj.fr/fd?e=07702354&debug&screenshot&killApp&idTest=second_test&serverUrl=%22http%3A%2F%2F10.234.226.106%3A8080%2F%2FexternalLink%22&paramsList=%22topScreenName,codeEtab%22
    
    print(url.fragments)
  }
  
  private func launchSendingTimer() {
    
    self.timer = NSTimer.scheduledTimerWithTimeInterval(timerDuration, target: self, selector: "sendDatas", userInfo: nil, repeats: false)
  }
  
  private func sendDatas() {
    
    if let url = serverUrl {
      let request = NSMutableURLRequest(URL: url)
      request.HTTPMethod = "POST"
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      
      let values = ["06786984572365", "06644857247565", "06649998782227"]
      
      do {
        request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(values, options: [])
      }
      catch {
        
      }
      
      Alamofire.request(request)
        .responseJSON { response in
      }
    }
  }
}