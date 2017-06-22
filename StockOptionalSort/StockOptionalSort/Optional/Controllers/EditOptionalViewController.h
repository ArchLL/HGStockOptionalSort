//
//  EditOptionalViewController.h
//  TopMaster
//
//  Created by 中资北方 on 2017/6/7.
//  Copyright © 2017年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JQFMDB;

@interface EditOptionalViewController : UIViewController

@property (nonatomic, strong) NSMutableArray  * optionalList;
@property (nonatomic, strong) JQFMDB          * db;            //数据库
@property (nonatomic,   copy) NSString        * listTableName; //表名


@end
