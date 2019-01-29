//
//  OptionalEditCell.m
//  HGStockOptionalSort
//
//  Created by Arch on 2017/6/7.
//  Copyright © 2017年 sun. All rights reserved.
//

#import "OptionalEditCell.h"

@interface OptionalEditCell ()

@property (weak, nonatomic) IBOutlet UILabel *stockName;
@property (weak, nonatomic) IBOutlet UILabel *stockCode;
@property (weak, nonatomic) IBOutlet UIButton *stickBtn;//置顶

@end

@implementation OptionalEditCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self layoutSubviews];
}


//置顶按钮的点击事件
- (IBAction)buttonClickAaction:(UIButton *)sender {
    if (self.buttonClickBlock) {
        self.buttonClickBlock(self);
    }
}

- (void)setModel:(OptionalMarketModel *)model {
    _stockName.text = [model.Name substringFromIndex:1];//名字去除头部空格
    _stockCode.text = model.Label;
}

// 修改TableViewCell在编辑模式下选中按钮的图片
- (void)layoutSubviews
{
    [super layoutSubviews];
    for (UIControl *control in self.subviews) {
        if (![control isMemberOfClass:NSClassFromString(@"UITableViewCellEditControl")]){
            continue;
        }
        for (UIView *subView in control.subviews) {
            if (![subView isKindOfClass: [UIImageView class]]) {
                continue;
            }
            UIImageView *imageView = (UIImageView *)subView;
            if (self.selected) {
                imageView.image = [UIImage imageNamed:@"Optional_selected"]; // 选中时的图片
            } else {
                imageView.image = [UIImage imageNamed:@"Optional_notSelected"];   // 未选中时的图片
            }
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}


@end
