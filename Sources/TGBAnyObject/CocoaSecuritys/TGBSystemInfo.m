//
//  TGBSystemInfo.m
//  ClourdOC
//
//  Created by message on 2019/1/11.
//  Copyright © 2019年 message. All rights reserved.
//

#import "TGBSystemInfo.h"
#import <UIKit/UIKit.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CommonCrypto/CommonDigest.h>
#import <objc/runtime.h>
#import <sys/utsname.h>

@implementation TGBSystemInfo

+ (NSString *)getIphoneType {
  
  struct utsname TGBSystemInfo;
  uname(&TGBSystemInfo);
  
  NSString *platform = [NSString stringWithCString:TGBSystemInfo.machine encoding:NSASCIIStringEncoding];
  ////// iPhone
  if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone";
  
  if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
  
  if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
  
  if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
  if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4";
  if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
  
  if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
  
  if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
  if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
  
  if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c";
  if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c";
  
  if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s";
  if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s";
  
  if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
  
  if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
  
  if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
  
  if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
  
  if ([platform isEqualToString:@"iPhone8,4"]) return @"iPhone SE";
  
  if ([platform isEqualToString:@"iPhone9,1"]) return @"iPhone 7";
  if ([platform isEqualToString:@"iPhone9,3"]) return @"iPhone 7";
  
  if ([platform isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus";
  if ([platform isEqualToString:@"iPhone9,4"]) return @"iPhone 7 Plus";
  
  if ([platform isEqualToString:@"iPhone10,1"]) return @"iPhone 8";
  if ([platform isEqualToString:@"iPhone10,4"]) return @"iPhone 8";
  
  if ([platform isEqualToString:@"iPhone10,2"]) return @"iPhone 8 Plus";
  if ([platform isEqualToString:@"iPhone10,5"]) return @"iPhone 8 Plus";
  
  if ([platform isEqualToString:@"iPhone10,3"]) return @"iPhone X";
  if ([platform isEqualToString:@"iPhone10,6"]) return @"iPhone X";
  
  if ([platform isEqualToString:@"iPhone11,8"]) return @"iPhone XR";
  
  
  
  if ([platform isEqualToString:@"iPhone11,2"]) return @"iPhone XS";
  
  if ([platform isEqualToString:@"iPhone11,6"]) return @"iPhone XS Max";
  
  /// if ([platform isEqualToString:@""]) return @"";
  
  
  
  //// iPod
  if ([platform isEqualToString:@"iPod1,1"]) return @"iPod Touch 1";
  
  if ([platform isEqualToString:@"iPod2,1"]) return @"iPod Touch 2";
  
  if ([platform isEqualToString:@"iPod3,1"]) return @"iPod Touch 3";
  
  if ([platform isEqualToString:@"iPod4,1"]) return @"iPod Touch 4";
  
  if ([platform isEqualToString:@"iPod5,1"]) return @"iPod Touch 5";
  
  if ([platform isEqualToString:@"iPod7,1"]) return @"iPod touch 6";
  
  /// if ([platform isEqualToString:@""]) return @"";
  
  
  
  //// iPad
  if ([platform isEqualToString:@"iPad1,1"]) return @"iPad";
  
  if ([platform isEqualToString:@"iPad2,1"]) return @"iPad 2";
  
  if ([platform isEqualToString:@"iPad2,2"]) return @"iPad 2";
  
  if ([platform isEqualToString:@"iPad2,3"]) return @"iPad 2";
  
  if ([platform isEqualToString:@"iPad2,4"]) return @"iPad 2";
  
  if ([platform isEqualToString:@"iPad2,5"]) return @"iPad mini";
  
  if ([platform isEqualToString:@"iPad2,6"]) return @"iPad mini";
  
  if ([platform isEqualToString:@"iPad2,7"]) return @"iPad mini";
  
  if ([platform isEqualToString:@"iPad3,1"]) return @"iPad 3";
  
  if ([platform isEqualToString:@"iPad3,2"]) return @"iPad 3";
  
  if ([platform isEqualToString:@"iPad3,3"]) return @"iPad 3";
  
  if ([platform isEqualToString:@"iPad3,4"]) return @"iPad 4";
  
  if ([platform isEqualToString:@"iPad3,5"]) return @"iPad 4";
  
  if ([platform isEqualToString:@"iPad3,6"]) return @"iPad 4";
  
  if ([platform isEqualToString:@"iPad4,1"]) return @"iPad Air";
  
  if ([platform isEqualToString:@"iPad4,2"]) return @"iPad Air";
  
  if ([platform isEqualToString:@"iPad4,3"]) return @"iPad Air";
  
  if ([platform isEqualToString:@"iPad4,4"]) return @"iPad mini 2";
  
  if ([platform isEqualToString:@"iPad4,5"]) return @"iPad mini 2";
  
  if ([platform isEqualToString:@"iPad4,6"]) return @"iPad mini 2";
  
  if ([platform isEqualToString:@"iPad4,7"]) return @"iPad mini 3";
  
  if ([platform isEqualToString:@"iPad4,8"]) return @"iPad mini 3";
  
  if ([platform isEqualToString:@"iPad4,9"]) return @"iPad mini 3";
  
  if ([platform isEqualToString:@"iPad5,1"]) return @"iPad mini 4";
  
  if ([platform isEqualToString:@"iPad5,2"]) return @"iPad mini 4";
  
  if ([platform isEqualToString:@"iPad5,3"]) return @"iPad Air 2";
  
  if ([platform isEqualToString:@"iPad5,4"]) return @"iPad Air 2";
  
  if ([platform isEqualToString:@"iPad6,3"]) return @"iPad Pro (9.7-inch)";
  
  if ([platform isEqualToString:@"iPad6,4"]) return @"iPad Pro (9.7-inch)";
  
  if ([platform isEqualToString:@"iPad6,7"]) return @"iPad Pro (12.9-inch)";
  
  if ([platform isEqualToString:@"iPad6,8"]) return @"iPad Pro (12.9-inch)";
  
  if ([platform isEqualToString:@"iPad6,11"]) return @"iPad 5";
  
  if ([platform isEqualToString:@"iPad6,12"]) return @"iPad 5";
  
  if ([platform isEqualToString:@"iPad7,1"]) return @"iPad Pro (12.9-inch, 2nd generation)";
  
  if ([platform isEqualToString:@"iPad7,2"]) return @"iPad Pro (12.9-inch, 2nd generation)";
  
  if ([platform isEqualToString:@"iPad7,3"]) return @"iPad Pro (10.5-inch)";
  
  if ([platform isEqualToString:@"iPad7,4"]) return @"iPad Pro (10.5-inch)";
  
  if ([platform isEqualToString:@"iPad7,5"]) return @"iPad 6";
  
  if ([platform isEqualToString:@"iPad7,6"]) return @"iPad 6";
  
  /// if ([platform isEqualToString:@""]) return @"";
  
  
  
  //// iWatch
  if ([platform isEqualToString:@"Watch1,1"]) return @"Apple Watch";
  
  if ([platform isEqualToString:@"Watch1,2"]) return @"Apple Watch";
  
  if ([platform isEqualToString:@"Watch2,6"]) return @"Apple Watch Series 1";
  
  if ([platform isEqualToString:@"Watch2,7"]) return @"Apple Watch Series 1";
  
  if ([platform isEqualToString:@"Watch2,3"]) return @"Apple Watch Series 2";
  
  if ([platform isEqualToString:@"Watch2,4"]) return @"Apple Watch Series 2";
  
  if ([platform isEqualToString:@"Watch3,1"]) return @"Apple Watch Series 3";
  
  if ([platform isEqualToString:@"Watch3,2"]) return @"Apple Watch Series 3";
  
  if ([platform isEqualToString:@"Watch3,3"]) return @"Apple Watch Series 3";
  
  if ([platform isEqualToString:@"Watch3,4"]) return @"Apple Watch Series 3";
  
  if ([platform isEqualToString:@"Watch4,1"]) return @"Apple Watch Series 4";
  
  if ([platform isEqualToString:@"Watch4,2"]) return @"Apple Watch Series 4";
  
  if ([platform isEqualToString:@"Watch4,3"]) return @"Apple Watch Series 4";
  
  if ([platform isEqualToString:@"Watch4,4"]) return @"Apple Watch Series 4";
  //// if ([platform isEqualToString:@""]) return @"";
  
  
  if ([platform isEqualToString:@"i386"]) return @"iPhone Simulator";
  //
  if ([platform isEqualToString:@"x86_64"]) return @"iPhone Simulator";
  
  return platform;
  
}


@end
