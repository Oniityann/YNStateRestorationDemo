//
//  YNItemHandler.m
//  YNStateRestoration
//
//  Created by 郑一楠 on 2017/1/4.
//  Copyright © 2017年 zyn. All rights reserved.
//

#import "YNItemHandler.h"
#import "YNCustomItem.h"

@implementation YNItemHandler

- (NSMutableArray *)allItems {
    
    if (!_allItems) {
        _allItems = [NSMutableArray arrayWithCapacity:0];
    }
    return _allItems;
}

+ (instancetype)sharedStore {
    
    static YNItemHandler *sharedStore = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedStore = [[self alloc] initPrivate];
    });
    
    return sharedStore;
}

- (instancetype)initPrivate {
    
    self = [super init];
    
    if (self) {
        
        NSString *path = [self itemPath];
        
        _allItems = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        if (!_allItems) {
            
            _allItems = [NSMutableArray array];
        }
    }
    
    return self;
}

- (YNCustomItem *)createItem {
    
    YNCustomItem *item = [[YNCustomItem alloc] init];
    
    [self.allItems addObject:item];
    
    return item;
}

- (void)removeItem:(YNCustomItem *)item {
    
    [self.allItems removeObjectIdenticalTo:item];
}

- (NSString *)itemPath {
    
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [documentDirectories firstObject];
    
    return [documentDirectory stringByAppendingPathComponent:@"items.archive"];
}

- (BOOL)saveItems {
    
    NSString *path = [self itemPath];
    
    return [NSKeyedArchiver archiveRootObject:self.allItems toFile:path];
}

@end
