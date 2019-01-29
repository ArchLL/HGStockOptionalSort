//
//  EditOptionalViewController.h
//  HGStockOptionalSort
//
//  Created by Arch on 2017/6/7.
//  Copyright © 2017年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JQFMDB;

@interface EditOptionalViewController : UIViewController
@property (nonatomic, strong) NSMutableArray *optionalList;
@property (nonatomic, strong) JQFMDB *db;
@property (nonatomic, copy) NSString *listTableName;

@end
