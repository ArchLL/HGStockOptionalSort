//
//  OptionalListCell.m
//  TopMaster
//
//  Created by 中资北方 on 2017/4/24.
//  Copyright © 2017年 sun. All rights reserved.
//

#import "OptionalListCell.h"

@interface OptionalListCell ()

@property (weak, nonatomic) IBOutlet UILabel *stockNameLB;
@property (weak, nonatomic) IBOutlet UILabel *stockCodeLB;



@end

@implementation OptionalListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setModel:(OptionalMarketModel *)model {
    _stockNameLB.text = [model.Name substringFromIndex:1];//数据里面的名称头部有空格，去除
    _stockCodeLB.text = model.Label;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
