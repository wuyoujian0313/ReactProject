//
//  NSObject+RNUpdateSupport.h
//  ReactProject
//
//  Created by wuyj on 16/3/24.
//  Copyright © 2016年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RCTRootView;
typedef void(^CompletionBlock)(BOOL result);

@interface NSObject (RNUpdateSupport)

- (BOOL)copyMainBundleFileToDocumentsDirectory;
- (BOOL)hasJSInDocumentsDirectory;

- (RCTRootView *)getRCRootViewWithModuleName:(NSString *)moduleName
                               launchOptions:(NSDictionary *)launchOptions;

- (void)downloadJSFrom:(NSString *)srcURLString completeHandler:(CompletionBlock)complete;


@end
