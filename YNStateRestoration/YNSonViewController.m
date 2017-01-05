//
//  YNSonViewController.m
//  YNStateRestoration
//
//  Created by 郑一楠 on 2017/1/4.
//  Copyright © 2017年 zyn. All rights reserved.
//

#import "YNSonViewController.h"
#import "YNCustomItem.h"
#import "YNItemHandler.h"

@interface YNSonViewController () <UIViewControllerRestoration>

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *sexLabel;

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextField *sexField;

@end

static NSString *const kRestorationKey = @"RestorationKey";

@implementation YNSonViewController

#pragma mark - initial

+ (YNSonViewController *)newItem:(BOOL)isNew {
    
    YNSonViewController *sonVC = [[YNSonViewController alloc] initWithNewItem:isNew];
    
    return sonVC;
}

- (instancetype)initWithNewItem:(BOOL)isNew {
    
    self = [super initWithNibName:nil bundle:nil];
    
    if (self) {
        
        // 设置恢复类和恢复标识
        self.restorationIdentifier = NSStringFromClass([self class]);
        self.restorationClass = [self class];
        
        NSLog(@"%@", self.item);
        
        if (isNew) {
            
            UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save:)];
            self.navigationItem.rightBarButtonItem = doneItem;
            
            UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
            self.navigationItem.leftBarButtonItem = cancelItem;
        }
    }
    return self;
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setupViewData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
    
    YNCustomItem *item = self.item;
    item.name = self.nameField.text;
    item.phoneNumber = [self.phoneField.text integerValue];
    item.sex = self.sexField.text;
}

- (void)setupViewData {
    
    self.nameField.text = self.item.name;
    self.phoneField.text = [NSString stringWithFormat:@"%ld", self.item.phoneNumber];
    self.sexField.text = self.item.sex;
}

#pragma mark - view controller restoration

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {
    
    BOOL isNew = NO;
    
    if (identifierComponents.count == 3) {
        isNew = YES;
    }
    
    return [[self alloc] initWithNewItem:isNew];
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.item.itemKey forKey:kRestorationKey];
    
    // 保存 textField 中的文本, 以便恢复更改后的文本
    self.item.name = self.nameField.text;
    self.item.phoneNumber = [self.phoneField.text integerValue];
    self.item.sex = self.sexField.text;
    
    // 存入本地
    [[YNItemHandler sharedStore] saveItems];
    
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    
    NSString *itemKey = [coder decodeObjectForKey:kRestorationKey];
    
    for (YNCustomItem *item in [[YNItemHandler sharedStore] allItems]) {
        if ([item.itemKey isEqualToString:itemKey]) {
            self.item = item;
            NSLog(@"name:%@, phone:%ld, sex:%@", self.item.name, self.item.phoneNumber, self.item.sex);
            break;
        }
    }
    
    [super decodeRestorableStateWithCoder:coder];
}

#pragma mark - memory warning

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - target / action

- (void)save:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancel:(UIBarButtonItem *)sender {
    
    [[YNItemHandler sharedStore] removeItem:self.item];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - others

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)setItem:(YNCustomItem *)item {
    
    if (_item != item) {
        _item = item;
    }
    self.navigationItem.title = self.item.name;
}

@end
