//
//  AppDelegate.m
//  UUBabyBluetoothDemo
//
//  Created by lhn on 17/1/5.
//  Copyright © 2017年 lhn. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
//#import "UUTableViewController.h"
//#import "UUCustomTableVC.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //tabbar文字颜色
    [[UITabBar appearance]setTintColor:[UIColor colorWithRed:233/255.0 green:80/255.0 blue:255/255.0 alpha:1]];
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    [self.window makeKeyAndVisible];
    
    [self createViews];

    
    return YES;
}

- (void)createViews {
    
    HomeViewController *homeView = [HomeViewController new];
    UINavigationController *homeNavg = [[UINavigationController alloc]initWithRootViewController:homeView];
    homeNavg.tabBarItem.image = [[UIImage imageNamed:@"Recommend_nor"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //给 tabBarItem 设置选中时的图片
    homeNavg.tabBarItem.selectedImage = [[UIImage imageNamed:@"Recommend_h"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    homeView.title = @"首页";
    
//    UUTableViewController *uuTableVC = [UUTableViewController new];
//    UINavigationController *uuTableNavg = [[UINavigationController alloc]initWithRootViewController:uuTableVC];
//    uuTableNavg.tabBarItem.image = [[UIImage imageNamed:@"Recommend_nor"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    //给 tabBarItem 设置选中时的图片
//    uuTableNavg.tabBarItem.selectedImage = [[UIImage imageNamed:@"Recommend_h"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    uuTableVC.title = @"测试";
//    
//    UUCustomTableVC *uucustomV = [UUCustomTableVC new];
//    UINavigationController *uucustomNavg = [[UINavigationController alloc]initWithRootViewController:uucustomV];
//    uucustomNavg.tabBarItem.image = [[UIImage imageNamed:@"Recommend_nor"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    //给 tabBarItem 设置选中时的图片
//    uucustomNavg.tabBarItem.selectedImage = [[UIImage imageNamed:@"Recommend_h"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    uucustomV.title = @"全部内容";
    
    UITabBarController *tabBarController = [[UITabBarController alloc]init];
    tabBarController.viewControllers = @[homeNavg];
    self.window.rootViewController = tabBarController;
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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
