//
//  YNMainTableController.m
//  YNStateRestoration
//
//  Created by 郑一楠 on 2017/1/4.
//  Copyright © 2017年 zyn. All rights reserved.
//

#import "YNMainTableController.h"
#import "YNSonViewController.h"
#import "YNTableViewCell.h"
#import "YNCustomItem.h"
#import "YNItemHandler.h"

@interface YNMainTableController () <UIViewControllerRestoration, UIDataSourceModelAssociation>

@end

static NSString *const kCellIdentifier = @"YNTableViewCell";
static NSString *const kTableViewIdentifier = @"YNMainControllerTableView";
static NSString *const kTableViewEditingKey = @"TableVewIsEditing";

@implementation YNMainTableController

#pragma mark - initial

- (instancetype)init {
    
    self = [super initWithStyle:UITableViewStylePlain];
    
    if (self) {
        
        // 设置恢复标识和恢复类
        self.restorationIdentifier = NSStringFromClass([self class]);
        self.restorationClass = [self class];
        
        self.navigationItem.title = @"State Restoration";
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewItem:)];
        self.navigationItem.leftBarButtonItem = self.editButtonItem;
    }
    
    return self;
}

#pragma mark - life cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([YNTableViewCell class]) bundle:nil] forCellReuseIdentifier:kCellIdentifier];
    
    // 给 tableView 设置恢复标识
    self.tableView.restorationIdentifier = kTableViewIdentifier;
    self.tableView.rowHeight = 100;
}

#pragma mark - view controller restoration

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {
    return [[self alloc] init];
}

// 记录 tableView 是否处于编辑状态
- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [coder encodeBool:self.isEditing forKey:kTableViewEditingKey];
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    self.editing = [coder decodeBoolForKey:kTableViewEditingKey];
    [super decodeRestorableStateWithCoder:coder];
}

#pragma mark - data source model association

- (NSString *)modelIdentifierForElementAtIndexPath:(NSIndexPath *)idx inView:(UIView *)view {
    NSString *identifier = nil;
    
    if (idx && view) {
        YNCustomItem *item = [[YNItemHandler sharedStore] allItems][idx.row];
        identifier = item.itemKey;
    }
    
    return identifier;
}

- (NSIndexPath *)indexPathForElementWithModelIdentifier:(NSString *)identifier inView:(UIView *)view {
    
    NSIndexPath *indexPath = nil;
    
    if (identifier && view) {
        
        for (YNCustomItem *item in [[YNItemHandler sharedStore] allItems]) {
            
            if ([identifier isEqualToString:item.itemKey]) {
                NSInteger row = [[[YNItemHandler sharedStore] allItems] indexOfObjectIdenticalTo:item];
                indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                break;
            }
        }
    }
    
    return indexPath;
}

#pragma mark - target / action

- (void)addNewItem:(id)sender {
    
    YNCustomItem *item = [[YNItemHandler sharedStore] createItem];
    
    YNSonViewController *sonVC = [YNSonViewController newItem:YES];
    sonVC.item = item;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:sonVC];
    
    // 为 UINavigationController 设置恢复类
    nav.restorationIdentifier = NSStringFromClass([nav class]);
    
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[YNItemHandler sharedStore] allItems].count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YNTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    YNCustomItem *item = [[YNItemHandler sharedStore] allItems][indexPath.row];
    
    cell.item = item;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YNCustomItem *selectedItem = [[YNItemHandler sharedStore] allItems][indexPath.row];
    
    YNSonViewController *sonVC = [YNSonViewController newItem:NO];
    
    sonVC.item = selectedItem;
    
    [self.navigationController pushViewController:sonVC animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        
    }
}

@end
