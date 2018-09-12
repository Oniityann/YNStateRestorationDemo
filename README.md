# iOS APP 状态恢复

## 前言

最近项目需求加上状态恢复, 记得之前在书上看过, 这次单独抽出这个功能实现详细梳理一下, 方便自己温习一下, 也方便不知道的 developer 学习. 


## 状态恢复?

举个栗子:

在使用名字为 A 的 app 时, 从列表页面进入详情页面, 这时你不想看了, 点击 Home 键, 回到后台, 打开 B 开始玩. 过了一段时间之后, 由于 A 没有写后台运行的功能, 这时, 系统会关闭 A, 再打开时, 你看到的是之前进入的详情页面.

系统一点的话说就是, 系统在进入后台时会保存 app 的层次结构, 在下一次进入的时候会恢复这个结构中所有的 controller. 系统在终止之前会遍历结构中每一个节点, 恢复标识, 类, 保存的数据. 在终止应用之后, 系统会把这些信息存储在系统文件中.

## 恢复标识

一般和对象的类名相同, 其类被称为恢复类.


## 实现

下面通过一个 demo 演示状态恢复的实现, 这个 demo 是一个保存联系人信息的 demo. 以下代码以 demo 中控制器为例. 建议 demo 和本文一起看, 更好理解.

### 1. 开启

默认情况下, app 的状态恢复是关闭的, 需要我们手动开启.
在 AppDelegate.m 中手动打开:

```objc
#pragma mark - open state restoration

// 和NSCoding协议方法有点像, encode, decode
- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder {
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder {
    return YES;
}
```

系统在保存 app 状态时, 会先从 root VC 去查询是否有`restorationIdentifier`属性, 如果有, 则保存状态, 继续查询其子控制器, 有则保存. 直到找不到带有`restorationIdentifier`的子控制器, 系统会停止保存其与其子控制器的状态.

画个图解释一下:
![状态恢复示意图](http://oupcsiea7.bkt.clouddn.com/WechatIMG7444.jpeg)

上图三级 VC 即使有`restorationIdentifier`也不会恢复.

`application:willFinishLaunchingWithOptions:`方法会在启用状态恢复之前调用, 我们需要将触发启用方法之前的代码写在这个方法中.

```objc
- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] init];
    self.window.frame = [UIScreen mainScreen].bounds;
    self.window.backgroundColor = [UIColor whiteColor];
    
    return YES;
}
```

然后为根视图控制器添加恢复标识:

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 如果没有触发恢复, 则重新设置根控制器
    if (!self.window.rootViewController) {
        
        YNMainTableController *table = [[YNMainTableController alloc] init];
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:table];
        
        nav.restorationIdentifier = NSStringFromClass([nav class]);
        
        self.window.rootViewController = nav;
    }
    
    [self.window makeKeyAndVisible];
    
    return YES;
}
```

### 2. 为子控制器实现

#### a. 设置恢复标识和恢复类

在一级控制器初始化方法中为其设置:

```objc
#pragma mark - initial

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        // 设置恢复标识和恢复类
        self.restorationIdentifier = NSStringFromClass([self class]);
        self.restorationClass = [self class];
    }
    
    return self;
}
```

在子控制器中设置:

```objc
- (instancetype)initWithNewItem:(BOOL)isNew {
    
    self = [super initWithNibName:nil bundle:nil];
    
    if (self) {
        
        // 设置恢复类和恢复标识
        self.restorationIdentifier = NSStringFromClass([self class]);
        self.restorationClass = [self class];
        
        if (isNew) {
            
            UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save:)];
            self.navigationItem.rightBarButtonItem = doneItem;
            
            UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
            self.navigationItem.leftBarButtonItem = cancelItem;
        }
    }
    
    return self;
}
```

如果是模态推出带有`navigationController`的控制器, 需要为这个 nav 设置恢复标识:

```objc
- (void)addNewItem:(id)sender {
    
    YNCustomItem *item = [[YNItemHandler sharedStore] createItem];
    
    YNSonViewController *sonVC = [YNSonViewController newItem:YES];
    sonVC.item = item;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:sonVC];
    
    // 为 UINavigationController 设置恢复类
    nav.restorationIdentifier = NSStringFromClass([nav class]);
    
    [self presentViewController:nav animated:YES completion:nil];
}
```

#### b. 遵循恢复协议

需要状态恢复的控制器需要遵循`<UIViewControllerRestoration>`协议:

一级视图控制器中:

```objc
#pragma mark - view controller restoration

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {
    return [[self alloc] init];
}
```

同样, 二级视图控制器中, demo 中添加新联系人信息和查看联系人信息调用的是同一个控制器, 初始化方法为自己封装的方法`newItem:(BOOL)isNew`, isNew 为 NO 时, 查看联系人, 为 YES 时, 新建联系人. 此时有两种情况:

1. 新建联系人:
	
	在恢复状态时`newItem:(BOOL)isNew`参数传入 YES
	
2. 查看联系人:
	
	参数传入 NO
	
那么如何判断传入什么参数呢? 通过

```objc
+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder;
```
方法中的`identifierComponents`来判断, `identifierComponents`存储了当前视图控制器及其所有上级视图控制器的恢复标识. 那么现在我们来看一下:

1. 新建联系人程序中的恢复标识有:
	 1. root VC 的 nav 恢复标识
	 2. 二级 VC 的 nav 恢复标识(没有一级 VC 的标识是因为 二级 VC 是由一级 VC 的 nav 模态出来的)
	 3. 二级 VC 自身的恢复标识
2. 查看联系人的恢复标识有:
	 1. 根 VC 的 nav 恢复标识
	 2. 二级 VC 自身的恢复标识(没有一级的和上面同理)
	
所以新建联系人的 VC 的`identifierComponents`的个数为3, 查看联系人的为2个. 那么则可以判断参数如何传递:

```objc
#pragma mark - view controller restoration

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {
    
    BOOL isNew = NO;
    
    if (identifierComponents.count == 3) {
        isNew = YES;
    }
    
    return [[self alloc] initWithNewItem:isNew];
}
```

#### c. 为 nav 设置恢复类

```objc
// 如果某个对象没有设置恢复类, 那么系统会通过 AppDelegate 来创建
- (UIViewController *)application:(UIApplication *)application viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {
    
    UINavigationController *nav = [[UINavigationController alloc] init];
    
    // 恢复标识路径中最后一个对象就是 nav 的恢复标识
    nav.restorationIdentifier = [identifierComponents lastObject];
    
    if (identifierComponents.count == 1) {
        self.window.rootViewController = nav;
    }
    
    return nav;
}
```

至此, 控制器的状态恢复已完成, 但是现实的数据还需要做持久化处理, 否则只是恢复了一个没有数据的控制器.

#### d. 数据持久化

使二级页面详情页需要的数据保存:

```objc
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
```

二级页面状态恢复完成, 这时候测试(测试方法: 运行后, cmd + shift + h回到桌面, Xcode停止运行, 然后再运行), 重新打开项目, 发现视图控制器状态是恢复了, 但是数据还是空白. 然后打上断点看了下周期, 把数据获取方法写在`viewWillAppear:`里就好了.

#### e. 记录 tableview 状态

为一级 VC 设置其 tableView 的恢复标识:

```objc
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"State Restoration";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewItem:)];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([YNTableViewCell class]) bundle:nil] forCellReuseIdentifier:kCellIdentifier];
    
    // 给 tableView 设置恢复标识, tableView 自动保存的 contentOffset 会恢复其滚动位置
    self.tableView.restorationIdentifier = kTableViewIdentifier;
}
```

记录 tableView 是否处于 editing 状态:

```objc
// 记录 tableView 是否处于编辑状态
- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [coder encodeBool:self.isEditing forKey:kTableViewEditingKey];
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    self.editing = [coder decodeBoolForKey:kTableViewEditingKey];
    [super decodeRestorableStateWithCoder:coder];
}
```

通过`<UIDataSourceModelAssociation>`协议使视图对象在恢复时关联正确的 model 对象. 当保存状态时, 其会根据 indexPath 保存一个唯一标识.

实现`<UIDataSourceModelAssociation>`协议方法:

```objc
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
```

最后记得在进入后台前持久化当前的 item(实际开发中记得用 cache(项目里使用 YYCache) 或者 db(项目里使用 FMDB) 去即时持久化视图数据, 是一个比较稳妥的方案):

```objc
- (void)applicationDidEnterBackground:(UIApplication *)application {
    BOOL success = [[YNItemHandler sharedStore] saveItems];
    
    if (success) {
        NSLog(@"成功保存所有项目");
    } else {
        NSLog(@"保存项目失败");
    }
}
```

至此, 状态恢复基本使用已经实现.

***

## 测试流程

1. 添加 n 个新的联系人, 滑动列表到测试位置, 让 tableView 进入到编辑状态. 按下`cmd + shift + h`进入 home, 用 Xcode 结束程序`cmd+.`, 再次运行看看是否在最后滑动位置, 或者是否处于编辑状态.
2. 恢复编辑状态, 随便进入一个联系人详情, 重复上面的操作, 看看进入程序之后是否处于上次退出前的详情页面.






