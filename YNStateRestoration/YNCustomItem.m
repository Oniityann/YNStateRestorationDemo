//
//  YNCustomItem.m
//  YNStateRestoration
//
//  Created by 郑一楠 on 2017/1/4.
//  Copyright © 2017年 zyn. All rights reserved.
//

#import "YNCustomItem.h"

static NSString *const kItemKey = @"item";
static NSString *const kNameKey = @"name";
static NSString *const kPhoneKey = @"phoneNumber";
static NSString *const kSexKey = @"sex";

@implementation YNCustomItem

- (instancetype)initWithName:(NSString *)name
                withPhoneNum:(NSInteger)phoneNum
                      andSex:(NSString *)sex {
    
    self = [super init];
    
    if (self) {
        
        NSUUID *uuid = [[NSUUID alloc] init];
        NSString *key = [uuid UUIDString];
        _itemKey = key;
        
        _name = name;
        _phoneNumber = phoneNum;
        _sex = sex;
    }
    
    return self;
}

- (instancetype)init {
    return [self initWithName:@"Name" withPhoneNum:0 andSex:@"Male"];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.itemKey forKey:kItemKey];
    [aCoder encodeObject:self.name forKey:kNameKey];
    [aCoder encodeInteger:self.phoneNumber forKey:kPhoneKey];
    [aCoder encodeObject:self.sex forKey:kSexKey];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super init];
    
    if (self) {
        _itemKey = [aDecoder decodeObjectForKey:kItemKey];
        _name = [aDecoder decodeObjectForKey:kNameKey];
        _phoneNumber = [aDecoder decodeIntegerForKey:kPhoneKey];
        _sex = [aDecoder decodeObjectForKey:kSexKey];
    }
    
    return self;
}

@end
