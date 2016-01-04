//
//  NSURLExtension.swift
//  CondomSDK
//
//  Created by Xavier De Koninck on 04/01/2016.
//  Copyright © 2016 PagesJaunes. All rights reserved.
//

import Foundation

extension NSURL {
  
  var fragments: [String: String] {
    var results = [String: String]()
    if let pairs = self.fragment?.componentsSeparatedByString("&") where pairs.count > 0 {
      for pair: String in pairs {
        if let keyValue = pair.componentsSeparatedByString("=") as [String]? {
          if(keyValue.count > 1) {
            results.updateValue(keyValue[1], forKey: keyValue[0])
          }
        }
      }
    }
    return results
  }
}