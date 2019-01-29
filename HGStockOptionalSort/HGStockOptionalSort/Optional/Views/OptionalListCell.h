//
//  OptionalListCell.h
//  HGStockOptionalSort
//
//  Created by Arch on 2017/4/24.
//  Copyright © 2017年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OptionalMarketModel.h"

@interface OptionalListCell : UITableViewCell

//赋值
@property (nonatomic, strong) OptionalMarketModel * model;

@end
