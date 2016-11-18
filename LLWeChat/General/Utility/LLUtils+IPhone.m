//
//  LLUtils+IPhone.m
//  LLWeChat
//
//  Created by GYJZH on 9/10/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLUtils+IPhone.h"
#import "LLUtils+Popover.h"
#include <sys/sysctl.h>


@implementation LLUtils (IPhone)

+ (CGFloat)systemVersion {
    static CGFloat _version;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _version = [[UIDevice currentDevice].systemVersion floatValue];
    });
    return _version;
}

+ (BOOL)canUsePhotiKit {
    return [self systemVersion] >= 8.0;
}

+ (void)callPhoneNumber:(NSString *)phone {
    NSString * str=[[NSString alloc] initWithFormat:@"telprompt://%@",phone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}

+ (void)copyToPasteboard:(NSString *)string {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = string;
    
}

+ (NSString *)appName {
 //   NSString *appName = NSLocalizedStringFromTable(@"CFBundleDisplayName", @"InfoPlist.strings", @"");
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleName"];
    return app_Name;
}


+ (LLNetconnectionType)getNetconnectionType {
    LLNetconnectionType netconnType;
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.apple.com"];
    
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            netconnType = kLLNetconnectionTypeNone;
            break;
        case ReachableViaWiFi:
            netconnType = kLLNetconnectionTypeWifi;
            break;
            // 手机自带网络
        case ReachableViaWWAN:
        {
            // 获取手机网络类型
            CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
            NSString *currentStatus = info.currentRadioAccessTechnology;
            
            if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyGPRS"]) {
                //                netconnType = @"GPRS";
                netconnType = kLLNetconnectionTypeOther;
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyEdge"]) {
                //                netconnType = @"2.75G EDGE";
                netconnType = kLLNetconnectionType2G;
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyWCDMA"]){
                //                netconnType = @"3G";
                netconnType = kLLNetconnectionType3G;
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSDPA"]){
                //                netconnType = @"3.5G HSDPA";
                netconnType = kLLNetconnectionType3G;
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSUPA"]){
                //                netconnType = @"3.5G HSUPA";
                netconnType = kLLNetconnectionType3G;
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMA1x"]){
                //                netconnType = @"2G";
                netconnType = kLLNetconnectionType2G;
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORev0"]){
                //                netconnType = @"3G";
                netconnType = kLLNetconnectionType3G;
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevA"]){
                //                netconnType = @"3G";
                netconnType = kLLNetconnectionType3G;
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevB"]){
                //                netconnType = @"3G";
                netconnType = kLLNetconnectionType3G;
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyeHRPD"]){
                //                netconnType = @"HRPD";
                netconnType = kLLNetconnectionTypeOther;
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyLTE"]){
                //                netconnType = @"4G";
                netconnType = kLLNetconnectionType4G;
            }
        }
            break;
            
        default:
            break;
    }
    
    return netconnType;
}

+ (void)saveImageToPhotoAlbum:(UIImage *)image {
    UIImageWriteToSavedPhotosAlbum(image, [LLUtils sharedUtils], @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

+ (void)saveVideoToPhotoAlbum:(NSString *)videoPath {
    UISaveVideoAtPathToSavedPhotosAlbum(videoPath, [LLUtils sharedUtils], @selector(video:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        [LLUtils showMessageAlertWithTitle:nil message:@"保存照片失败"];
    }else {
        [LLUtils showActionSuccessHUD:@"已保存到系统相册"];
    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error
    contextInfo:(void *)contextInfo {
    if (error) {
        [LLUtils showMessageAlertWithTitle:nil message:@"保存视频失败"];
    }else {
        [LLUtils showActionSuccessHUD:@"已保存到系统相册"];
    }
}


+ (NSString *)getApplicationScheme
{
    NSDictionary *bundleInfo    = [[NSBundle mainBundle] infoDictionary];
    NSString *bundleIdentifier  = [[NSBundle mainBundle] bundleIdentifier];
    NSArray *URLTypes           = [bundleInfo valueForKey:@"CFBundleURLTypes"];
    
    NSString *scheme;
    for (NSDictionary *dic in URLTypes)
    {
        NSString *URLName = [dic valueForKey:@"CFBundleURLName"];
        if ([URLName isEqualToString:bundleIdentifier])
        {
            scheme = [[dic valueForKey:@"CFBundleURLSchemes"] objectAtIndex:0];
            break;
        }
    }
    
    return scheme;
}


+ (NSString*)devicePlatformVersion
{
    size_t size;
    sysctlbyname("hw.machine",NULL, &size, NULL,0);
    char *machine = (char*)malloc(size);
    sysctlbyname("hw.machine", machine, &size,NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return platform;
}



+ (NSString *)deviceModelName
{
    NSString *platform = [self devicePlatformVersion];
    //iPhone
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 1";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4s";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5C";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5C";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5S";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5S";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6 Plus";
    //iPot Touch
    if ([platform isEqualToString:@"iPod1,1"]) return @"iPod Touch";
    if ([platform isEqualToString:@"iPod2,1"]) return @"iPod Touch 2";
    if ([platform isEqualToString:@"iPod3,1"]) return @"iPod Touch 3";
    if ([platform isEqualToString:@"iPod4,1"]) return @"iPod Touch 4";
    if ([platform isEqualToString:@"iPod5,1"]) return @"iPod Touch 5";
    //iPad
    if ([platform isEqualToString:@"iPad1,1"]) return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"]) return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,2"]) return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,3"]) return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,4"]) return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,5"]) return @"iPad Mini 1";
    if ([platform isEqualToString:@"iPad2,6"]) return @"iPad Mini 1";
    if ([platform isEqualToString:@"iPad2,7"]) return @"iPad Mini 1";
    if ([platform isEqualToString:@"iPad3,1"]) return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,2"]) return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,3"]) return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,4"]) return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,5"]) return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,6"]) return @"iPad 4";
    if ([platform isEqualToString:@"iPad4,1"]) return @"iPad air";
    if ([platform isEqualToString:@"iPad4,2"]) return @"iPad air";
    if ([platform isEqualToString:@"iPad4,3"]) return @"iPad air";
    if ([platform isEqualToString:@"iPad4,4"]) return @"iPad mini 2";
    if ([platform isEqualToString:@"iPad4,5"]) return @"iPad mini 2";
    if ([platform isEqualToString:@"iPad4,6"]) return @"iPad mini 2";
    if ([platform isEqualToString:@"iPad4,7"]) return @"iPad mini 3";
    if ([platform isEqualToString:@"iPad4,8"]) return @"iPad mini 3";
    if ([platform isEqualToString:@"iPad4,9"]) return @"iPad mini 3";
    if ([platform isEqualToString:@"iPad5,3"]) return @"iPad air 2";
    if ([platform isEqualToString:@"iPad5,4"]) return @"iPad air 2";
    if ([platform isEqualToString:@"iPhone Simulator"] || [platform isEqualToString:@"x86_64"] || [platform isEqualToString:@"i386"]) return @"iPhone Simulator";
    return platform;
}

+ (void)setNetworkActivityIndicatorVisible:(BOOL)visible {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = visible;
}


@end
