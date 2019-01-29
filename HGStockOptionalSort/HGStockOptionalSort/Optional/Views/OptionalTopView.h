//
//  OptionalTopView.h
//  HGStockOptionalSort
//
//  Created by Arch on 2017/6/5.
//  Copyright © 2017年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OptionalTopView : UIView

@property (nonatomic, strong) UIScrollView * rightScrollView;//右边菜单栏的背景视图
@property (nonatomic, copy) void(^buttonClickBlock)(NSInteger tag);
@property (nonatomic, copy) void(^scrollViewBlock)(CGPoint offset);

- (instancetype)initWithFrame:(CGRect)frame withTitles:(NSArray *)titles;


@end
