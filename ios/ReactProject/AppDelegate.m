/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "AppDelegate.h"
#import "RCTRootView.h"
#import "NSObject+RNUpdateSupport.h"

@interface AppDelegate ()
@property(nonatomic,strong) RCTRootView *rootView;

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  // 在Release版本下，可以把本地这个JS拷贝到Document目录下
  [self copyMainBundleFileToDocumentsDirectory];
  
  NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
  self.rootView = [self getRCRootViewWithModuleName:appName launchOptions:launchOptions];
  
  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  UIViewController *rootViewController = [UIViewController new];
  rootViewController.view = _rootView;
  self.window.rootViewController = rootViewController;
  [self.window makeKeyAndVisible];
  
  

  // 从后端加载升级js
  NSString *base = @"http://cp01-rdqa-dev317.cp01.baidu.com:8099";
  NSString *uRLStr = [base stringByAppendingString:@"/main.jsbundle?platform=ios&dev=NO"];
  
  __weak RCTRootView *wRootView = _rootView;
  [self downloadJSFrom:uRLStr completeHandler:^(BOOL result) {
    //
    if (result) {
  
      dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC);
      dispatch_after(time, dispatch_get_main_queue(), ^{
        RCTRootView *sRootView = wRootView;
        [sRootView.bridge reload];
      });

//      // 主线程执行：
//      dispatch_async(dispatch_get_main_queue(), ^{
//        //
//        
//      });
    }
  }];
  
  return YES;
}

@end
