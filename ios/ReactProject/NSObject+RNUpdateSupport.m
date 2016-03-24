//
//  NSObject+RNUpdateSupport.m
//  ReactProject
//
//  Created by wuyj on 16/3/24.
//  Copyright © 2016年 Facebook. All rights reserved.
//

#import "NSObject+RNUpdateSupport.h"
#import "WYJMinNetworkManager.h"
#import <RCTRootView.h>
#import <RCTBridge.h>


@implementation NSObject (RNUpdateSupport)


- (NSString *)JSBundlePath {
  
  NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
  NSString *bundlePath = [docPath stringByAppendingPathComponent:@"JSBundle"];
  return bundlePath;
}


- (BOOL)copyMainBundleFileToDocumentsDirectory {
  
#if !DEBUG
  
  NSError *error = nil;
  NSFileManager* fileManager = [NSFileManager defaultManager];
  if (![fileManager fileExistsAtPath:[self JSBundlePath]]) {
    [fileManager createDirectoryAtPath:[self JSBundlePath] withIntermediateDirectories:YES attributes:nil error:&error];
  } else {
    [fileManager removeItemAtURL:[self URLForJSInDocumentsDirectory] error:nil];
  }
  
  NSString *bundleFilePath = [[NSBundle mainBundle] pathForResource:@"main" ofType:@"jsbundle"];
  if ([fileManager fileExistsAtPath:bundleFilePath]) {
    [fileManager copyItemAtPath:bundleFilePath toPath:[self pathForJSInDocumentsDirectory] error:&error];
  }
  
  if (error) {
    return NO;
  }
  return YES;
#else
  return NO;
#endif
}


- (NSURL *)URLForJSInDocumentsDirectory {
  return [NSURL fileURLWithPath:[self pathForJSInDocumentsDirectory]];
}

- (NSString *)pathForJSInDocumentsDirectory {
  
  NSString *fileName = [@"main" stringByAppendingPathExtension:@"jsbundle"];
  NSString *filePath = [[self JSBundlePath] stringByAppendingPathComponent:fileName];
  return filePath;
}

- (RCTRootView *)createRCRootViewWithURL:(NSURL *)url
                              moduleName:(NSString *)moduleName
                           launchOptions:(NSDictionary *)launchOptions {
  return [[RCTRootView alloc] initWithBundleURL:url
                                     moduleName:moduleName
                              initialProperties:nil
                                  launchOptions:launchOptions];
}

- (BOOL)resetJSBundlePath {
  
  NSError *error = nil;
  NSFileManager* fileManager = [NSFileManager defaultManager];
  [fileManager removeItemAtPath:[self JSBundlePath] error:&error];
  
  [fileManager createDirectoryAtPath:[self JSBundlePath] withIntermediateDirectories:YES attributes:nil error:&error];
  
  return error ? NO : YES;
}

- (BOOL)hasJSInDocumentsDirectory {
  
  NSFileManager* fileManager = [NSFileManager defaultManager];
  return [fileManager fileExistsAtPath:[self pathForJSInDocumentsDirectory]];
}

- (RCTBridge *)createBridgeWithBundleURL:(NSURL *)bundleURL {
  return [[RCTBridge alloc] initWithBundleURL:bundleURL moduleProvider:nil launchOptions:nil];
}

- (RCTRootView *)createCRRootViewWithModuleName:(NSString *)moduleName
                                         bridge:(RCTBridge *)bridge {
  return [[RCTRootView alloc] initWithBridge:bridge moduleName:moduleName initialProperties:nil];
}


- (RCTRootView *)getRCRootViewWithModuleName:(NSString *)moduleName
                               launchOptions:(NSDictionary *)launchOptions {
  
  NSURL *jsCodeLocationURL = nil;
  RCTRootView *rootView = nil;
  
#if DEBUG
  #if TARGET_OS_SIMULATOR
  // Debue下，模拟器
  jsCodeLocationURL = [NSURL URLWithString:@"http://localhost:8081/index.ios.bundle?platform=ios&dev=true"];
  
  #else
  // Debue下，真机
  // 需要输入本机的IP
  NSString *serverIP = @"172.22.182.86";
  NSString *jsCodeUrlString = [NSString stringWithFormat:@"http://%@:8081/index.ios.bundle?platform=ios&dev=true", serverIP];
  NSString *jsBundleUrlString = [jsCodeUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  jsCodeLocationURL = [NSURL URLWithString:jsBundleUrlString];
  
  #endif
  
  rootView = [self createRCRootViewWithURL:jsCodeLocationURL moduleName:moduleName launchOptions:launchOptions];
  
#else
  
  // release下，编译之后RectNative会吧main.jsbundle拷贝到mainBundle里
  jsCodeLocationURL = [self URLForJSInDocumentsDirectory];
  if (![self hasJSInDocumentsDirectory]) {
    [self resetJSBundlePath];
    
    BOOL copyResult = [self copyMainBundleFileToDocumentsDirectory];
    if (!copyResult) {
      jsCodeLocationURL = [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];;
    }
  }
  RCTBridge* bridge = [self createBridgeWithBundleURL:jsCodeLocationURL];
  rootView = [self createCRRootViewWithModuleName:moduleName bridge:bridge];
  
#endif

  return rootView;
}

- (void)downloadJSFrom:(NSString *)srcURLString
       completeHandler:(CompletionBlock)complete {
  
#if !DEBUG
  [WYJMinNetworkManager sendWithHTTPMethod:HTTPMethodGET URLString:srcURLString parameters:nil error:nil completionHandler:^(NSData *data, NSURLResponse *response, NSError *connectionError) {
    //
    if (connectionError) {
      complete(NO);
      return;
    }
    
    if (data) {
      NSError *error = nil;
      [data writeToURL:[self URLForJSInDocumentsDirectory] options:(NSDataWritingAtomic) error:&error];
      if (error) {
        complete(NO);
        [self copyMainBundleFileToDocumentsDirectory];
      } else {
        complete(YES);
      }
    }
  }];
#else
  complete(NO);
#endif
}

@end
