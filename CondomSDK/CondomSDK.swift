//
//  CondomSDK.swift
//  CondomSDK
//
//  Created by Xavier De Koninck on 22/12/2015.
//  Copyright © 2015 PagesJaunes. All rights reserved.
//

import Foundation

@objc public class CondomSDK: NSObject {
  
  @objc public static let sharedInstance: CondomSDK = CondomSDK()
  
  private var datas: [String: String] = [String: String]()
  private var keys: [String] = [String]()
  private var killApp: Bool = false
  
  @objc override init() {
    
  }
  
  @objc public func setTestURL(url: NSURL) {
    
  }
  
  @objc public func resetDatas() {
    self.datas.removeAll()
  }
  
  @objc public func setTestValue(value: String, forKey key: String) {
    
  }
  
  private func sendDatas() {
    
  }
}