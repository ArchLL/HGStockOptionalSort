//
//  OptionalRightListCell.m
//  TopMaster
//
//  Created by 中资北方 on 2017/6/6.
//  Copyright © 2017年 sun. All rights reserved.
//

#import "OptionalRightListCell.h"


#define rightUnitViewWidth 100
#define increaseColor HexRGB(0xE74C3C)
#define decreaseColor HexRGB(0x41CB47)

@implementation OptionalRightListCell
{
    NSInteger _labelCount;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withUnitCount:(NSInteger)unitCount {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //设置UI
        [self setUIWithUnitCount:unitCount];
    }
    return self;
}

- (void)setUIWithUnitCount:(NSInteger)count {
    _labelCount = count;
    for (int i = 0; i < count; i++) {
        UILabel *label = [[UILabel alloc]init];
        label.textColor = [UIColor blackColor];
        label.backgroundColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:17];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"--";
        label.tag = 100 + i;
        label.frame = CGRectMake(i*rightUnitViewWidth, self.contentView.center.y, rightUnitViewWidth, 21);
        [self.contentView addSubview:label];
    }
    //分割线
    UIView *line = [[UIView alloc]init];
    line.backgroundColor = CellSeparator_Color;
    [self.contentView addSubview:line];
    [line  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.contentView).offset(0);
        make.height.mas_equalTo(1);
    }];
}

//赋值
- (void)setModel:(OptionalMarketModel *)model {
    for (int i = 0; i < _labelCount; i++) {
        UILabel *label = [self viewWithTag:100+i];
        switch (i) {
            case 0:
                //最新价
                label.text = [NSString stringWithFormat:@"%.2f",model.NewPrice.floatValue];
                if (model.NewPrice.floatValue > model.LastClose.floatValue) {
                    label.textColor = increaseColor;
                }else if(model.NewPrice.floatValue < model.LastClose.floatValue) {
                    label.textColor = decreaseColor;
                }else {
                    label.textColor = [UIColor blackColor];
                }
                break;
            case 1:
                //涨幅
                if (model.Gains.floatValue > 0) {
                     label.textColor = increaseColor;
                     label.text = [NSString stringWithFormat:@"+%.2f%%",model.Gains.floatValue];
                }else if (model.Gains.floatValue < 0) {
                     label.textColor = decreaseColor;
                     label.text = [NSString stringWithFormat:@"%.2f%%",model.Gains.floatValue];
                }else {
                     label.textColor = [UIColor blackColor];
                     label.text = [NSString stringWithFormat:@"%.2f%%",model.Gains.floatValue];
                }
                break;
            case 2:
                //涨跌
                label.text = [NSString stringWithFormat:@"%.2f",model.RiseFall.floatValue];
                if (model.RiseFall.floatValue > 0) {
                    label.textColor = increaseColor;
                }else if (model.RiseFall.floatValue < 0) {
                    label.textColor = decreaseColor;
                }else {
                    label.textColor = [UIColor blackColor];
                }
                break;
            case 3:
                //涨速
                label.text = [NSString stringWithFormat:@"%.2f%%",model.HigherSpeed.floatValue];
                if (model.HigherSpeed.floatValue > 0) {
                    label.textColor = increaseColor;
                }else if (model.HigherSpeed.floatValue < 0) {
                    label.textColor = decreaseColor;
                }else {
                    label.textColor = [UIColor blackColor];
                }
                break;
            case 4:
                //总手
                if (model.Hand.integerValue > 10000) {
                    label.text = [NSString stringWithFormat:@"%.2f万",model.Hand.integerValue/10000.f];
                }else if(model.Hand.integerValue > 100000000){
                    label.text = [NSString stringWithFormat:@"%.2f亿",model.Hand.integerValue/10000.f];
                }else {
                    label.text = model.Hand.stringValue;
                }
                break;
            case 5:
                //量比
                label.text = [NSString stringWithFormat:@"%.2f",model.VolumeRatio.floatValue];
                if (model.VolumeRatio.floatValue > 0) {
                    label.textColor = increaseColor;
                }else if (model.VolumeRatio.floatValue < 0) {
                    label.textColor = decreaseColor;
                }else {
                    label.textColor = [UIColor blackColor];
                }
                break;
            case 6:
                //开盘
                label.text = [NSString stringWithFormat:@"%.2f",model.Open.floatValue];
                if (model.Open.floatValue > 0) {
                    label.textColor = increaseColor;
                }else if (model.Open.floatValue < 0) {
                    label.textColor = decreaseColor;
                }else {
                    label.textColor = [UIColor blackColor];
                }
                break;
            case 7:
                //昨收
                label.text = [NSString stringWithFormat:@"%.2f",model.LastClose.floatValue];
                break;
            case 8:
                //最高
                label.text = [NSString stringWithFormat:@"%.2f",model.High.floatValue];
                if (model.High.floatValue > 0) {
                    label.textColor = increaseColor;
                }else if (model.High.floatValue < 0) {
                    label.textColor = decreaseColor;
                }else {
                    label.textColor = [UIColor blackColor];
                }
                break;
            case 9:
                //最低
                label.text = [NSString stringWithFormat:@"%.2f",model.Low.floatValue];
                if (model.Low.floatValue > 0) {
                    label.textColor = increaseColor;
                }else if (model.Low.floatValue < 0) {
                    label.textColor = decreaseColor;
                }else {
                    label.textColor = [UIColor blackColor];
                }
                break;
            case 10:
                //委比
                label.text = [NSString stringWithFormat:@"%.2f%%",model.AppointThan.floatValue];
                if (model.AppointThan.floatValue > 0) {
                    label.textColor = increaseColor;
                }else if (model.AppointThan.floatValue < 0) {
                    label.textColor = decreaseColor;
                }else {
                    label.textColor = [UIColor blackColor];
                }
                break;
                break;
            case 11:
                //振幅
                label.text = [NSString stringWithFormat:@"%.2f%%",model.Swing.floatValue];
                break;
            default:
                break;
        }
    }
}


- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
