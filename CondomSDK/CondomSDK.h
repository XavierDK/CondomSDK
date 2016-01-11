//
//  CondomSDK.h
//  CondomSDK
//
//  Created by Xavier De Koninck on 22/12/2015.
//  Copyright © 2015 PagesJaunes. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for CondomSDK.
FOUNDATION_EXPORT double CondomSDKVersionNumber;

//! Project version string for CondomSDK.
FOUNDATION_EXPORT const unsigned char CondomSDKVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <CondomSDK/PublicHeader.h>

#if defined(DEBUG)

#define CONDOM_SET_URL(X)             [CondomSDK.sharedInstance setTestURL:X]
#define CONDOM_SET_KEY_VALUE(X, Y)    [CondomSDK.sharedInstance setTestValue:Y forKey:X]
#define CONDOM_EXPECTED_FOR_SUBKEY(X) [CondomSDK.sharedInstance expectedKeysForSubKey:X]

#else

#define CONDOM_SET_URL(X)             ((void)0)
#define CONDOM_SET_KEY_VALUE(X, Y)    ((void)0)
#define CONDOM_EXPECTED_FOR_SUBKEY(X) ((void)0)

#endif

