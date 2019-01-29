//
//  HGDeviceModelHelper.h
//  StockOptionalSort
//
//  Created by Arch on 2018/9/17.
//  Copyright © 2018 Arch. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HGDeviceModelHelper : NSObject

+ (BOOL)isIPhoneX;
+ (CGFloat)safeAreaInsetsTop;
+ (CGFloat)safeAreaInsetsBottom;

@end

NS_ASSUME_NONNULL_END
