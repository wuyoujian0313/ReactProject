//
//  WYJMinNetworkManager.h
//  ReactProject
//
//  Created by wuyj on 16/3/24.
//  Copyright © 2016年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HTTPMethod) {
  HTTPMethodGET,
  HTTPMethodPOST,
};

typedef void(^CompletionHandleBlock)(NSData* data, NSURLResponse* response, NSError* connectionError);

@interface WYJMinNetworkManager : NSObject

+ (NSURLSessionDataTask *)sendWithHTTPMethod:(HTTPMethod)requestMethod URLString:(NSString *)urlString parameters:(NSDictionary *)parameters error:(NSError *__autoreleasing *)error completionHandler:(CompletionHandleBlock)completion;

@end
