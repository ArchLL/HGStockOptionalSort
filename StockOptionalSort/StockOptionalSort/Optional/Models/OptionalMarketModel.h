//
//  OptionalMarketModel.h
//  TopMaster
//
//  Created by 中资北方 on 2017/6/9.
//  Copyright © 2017年 sun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OptionalMarketModel : NSObject

@property (nonatomic, copy) NSString * Name;        //股票名称
@property (nonatomic, copy) NSString * Label;       //股票代码
@property (nonatomic, copy) NSNumber * NewPrice;    //最新价
@property (nonatomic, copy) NSNumber * Gains;       //涨幅
@property (nonatomic, copy) NSNumber * RiseFall;    //涨跌
@property (nonatomic, copy) NSNumber * HigherSpeed; //涨速
@property (nonatomic, copy) NSNumber * Hand;        //总手
@property (nonatomic, copy) NSNumber * VolumeRatio; //量比
@property (nonatomic, copy) NSNumber * Open;        //开盘价
@property (nonatomic, copy) NSNumber * LastClose;   //昨收
@property (nonatomic, copy) NSNumber * High;        //最高
@property (nonatomic, copy) NSNumber * Low;         //最低
@property (nonatomic, copy) NSNumber * AppointThan; //委比
@property (nonatomic, copy) NSNumber * Swing;       //振幅

@end

//{
//Label: "SH000152",
//Name: " 上央红利",
//NewPrice: 1971.55,
//Gains: 0.09,
//HigherSpeed: 0,
//VolumeRatio: -1.68,
//RiseFall: 1.68,
//Hand: 10101400,
//Open: 1967.56,
//LastClose: 1969.87,
//High: 1972.78,
//Low: 1961.01,
//Swing: 0.6,
//AppointThan: 0
//},
