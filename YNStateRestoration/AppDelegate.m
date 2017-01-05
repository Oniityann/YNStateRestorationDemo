//
//  AppDelegate.m
//  YNStateRestoration
//
//  Created by 郑一楠 on 2017/1/4.
//  Copyright © 2017年 zyn. All rights reserved.
//

#import "AppDelegate.h"
#import "YNMainTableController.h"
#import "YNItemHandler.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] init];
    self.window.frame = [UIScreen mainScreen].bounds;
    self.window.backgroundColor = [UIColor whiteColor];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 如果没有触发恢复, 则重新设置根控制器
    if (!self.window.rootViewController) {
    
        //设置窗口的根视图控制器
        YNMainTableController *table = [[YNMainTableController alloc] init];
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:table];
        
        nav.restorationIdentifier = NSStringFromClass([nav class]);
    
        self.window.rootViewController = nav;
    }
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

#pragma mark - open state restoration

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder {
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder {
    return YES;
}

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

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    BOOL success = [[YNItemHandler sharedStore] saveItems];
    
    if (success) {
        NSLog(@"成功保存所有项目");
    } else {
        NSLog(@"保存项目失败");
    }
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
