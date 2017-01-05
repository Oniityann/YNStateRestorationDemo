//
//  YNSonViewController.h
//  YNStateRestoration
//
//  Created by 郑一楠 on 2017/1/4.
//  Copyright © 2017年 zyn. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YNCustomItem;

@interface YNSonViewController : UIViewController

+ (YNSonViewController *)newItem:(BOOL)isNew;

- (instancetype)initWithNewItem:(BOOL)isNew;

@property (strong, nonatomic) YNCustomItem *item;

@end
