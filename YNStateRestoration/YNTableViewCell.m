//
//  YNTableViewCell.m
//  YNStateRestoration
//
//  Created by 郑一楠 on 2017/1/4.
//  Copyright © 2017年 zyn. All rights reserved.
//

#import "YNTableViewCell.h"
#import "YNCustomItem.h"

@interface YNTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *sexLabel;

@end

@implementation YNTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setItem:(YNCustomItem *)item {
    
    if (_item != item) {
        _item = item;
    }
    
    self.nameLabel.text = self.item.name;
    self.phoneLabel.text = [NSString stringWithFormat:@"%ld", self.item.phoneNumber];
    self.sexLabel.text = self.item.sex;
}

@end
