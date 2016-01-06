//
//  NSURLExtension.swift
//  CondomSDK
//
//  Created by Xavier De Koninck on 04/01/2016.
//  Copyright © 2016 PagesJaunes. All rights reserved.
//

import Foundation

extension NSURL {
  func getKeyVals() -> Dictionary<String, String>? {
    var results = [String:String]()
    let keyValues = self.query?.stringByRemovingPercentEncoding?.componentsSeparatedByString("&")
    if keyValues?.count > 0 {
      for pair in keyValues! {
        let kv = pair.componentsSeparatedByString("=")
        if kv.count > 1 {
          results.updateValue(kv[1], forKey: kv[0])
        }
        else if kv.count == 1 {
          results.updateValue("", forKey: kv[0])
        }
      }
      
    }
    return results
  }
}