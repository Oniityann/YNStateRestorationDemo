//
//  YNCustomItem.h
//  YNStateRestoration
//
//  Created by 郑一楠 on 2017/1/4.
//  Copyright © 2017年 zyn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YNCustomItem : NSObject <NSCoding>

@property (nonatomic, copy) NSString *itemKey;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *sex;
@property (nonatomic, assign) NSInteger phoneNumber;

- (instancetype)initWithName:(NSString *)name
                withPhoneNum:(NSInteger)phoneNum
                      andSex:(NSString *)sex;

@end
