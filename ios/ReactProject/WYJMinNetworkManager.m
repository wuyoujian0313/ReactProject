//
//  WYJMinNetworkManager.m
//  ReactProject
//
//  Created by wuyj on 16/3/24.
//  Copyright © 2016年 Facebook. All rights reserved.
//

#import "WYJMinNetworkManager.h"

@implementation WYJMinNetworkManager

static NSString * QueryStringFromParametersWithEncoding(NSDictionary *parameters, NSStringEncoding stringEncoding) {
  
  NSMutableArray *mutablePairs = [NSMutableArray array];
  [parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
    NSString *ercentEscapedKey = key;
    NSString *ercentEscapedValue = obj;
    if ([key isKindOfClass:[NSString class]]) {
      ercentEscapedKey = [key stringByAddingPercentEscapesUsingEncoding:stringEncoding];
    }
    if ([ercentEscapedValue isKindOfClass:[NSString class]]) {
      ercentEscapedValue = [key stringByAddingPercentEscapesUsingEncoding:stringEncoding];
    }
    NSString *pair = [NSString stringWithFormat:@"%@=%@", ercentEscapedKey, ercentEscapedValue];
    [mutablePairs addObject:pair];
  }];
  
  return [mutablePairs componentsJoinedByString:@"&"];
}

+ (NSURLSessionDataTask *)sendWithHTTPMethod:(HTTPMethod)requestMethod URLString:(NSString *)urlString parameters:(NSDictionary *)parameters error:(NSError *__autoreleasing *)error completionHandler:(CompletionHandleBlock)completion {
  
  NSString *method = @"GET";
  if (requestMethod == HTTPMethodPOST) {
    method = @"POST";
  }
  
  urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
  request.HTTPMethod = method;
  request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
  if (HTTPMethodPOST) {
    if (parameters) {
      request.HTTPBody = [QueryStringFromParametersWithEncoding(parameters, NSUTF8StringEncoding) dataUsingEncoding:NSUTF8StringEncoding];
    }
  }
  
  NSURLSession *session = [NSURLSession sharedSession];
  
  NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    if (completion) {
      completion(data, response, error);
    }
  }];
  [task resume];
  return task;
}

@end
