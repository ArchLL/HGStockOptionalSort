//
//  OptionalRightListCell.h
//  HGStockOptionalSort
//
//  Created by Arch on 2017/6/6.
//  Copyright © 2017年 Arch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OptionalMarketModel.h"

@interface OptionalRightListCell : UITableViewCell

@property (nonatomic, strong) OptionalMarketModel * model;

//unitCount :cell上unit个数
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withUnitCount:(NSInteger)unitCount;


@end
