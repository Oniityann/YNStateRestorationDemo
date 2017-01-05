//
//  YNItemHandler.h
//  YNStateRestoration
//
//  Created by 郑一楠 on 2017/1/4.
//  Copyright © 2017年 zyn. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YNCustomItem;

@interface YNItemHandler : NSObject

+ (instancetype)sharedStore;

- (YNCustomItem *)createItem;

- (void)removeItem:(YNCustomItem *)item;

- (BOOL)saveItems;

@property (nonatomic, strong) NSMutableArray *allItems;

@end
