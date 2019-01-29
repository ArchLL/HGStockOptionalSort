//
//  HGDeviceModelHelper.m
//  StockOptionalSort
//
//  Created by Arch on 2018/9/17.
//  Copyright © 2018 Arch. All rights reserved.
//

#import "HGDeviceModelHelper.h"

@implementation HGDeviceModelHelper

+ (BOOL)isIPhoneX {
    BOOL isIPhoneX = NO;
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {
        return isIPhoneX;
    }
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [UIApplication sharedApplication].delegate.window;
        if (mainWindow.safeAreaInsets.bottom > 0.0) {
            isIPhoneX = YES;
        }
    }
    return isIPhoneX;
}

+ (CGFloat)safeAreaInsetsBottom {
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [UIApplication sharedApplication].delegate.window;
        return mainWindow.safeAreaInsets.bottom;
    } else {
        return 0;
    }
}

+ (CGFloat)safeAreaInsetsTop {
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [UIApplication sharedApplication].delegate.window;
        return mainWindow.safeAreaInsets.top;
    } else {
        return 20;
    }
}

@end
