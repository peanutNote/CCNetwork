//
//  CCHTTPRequestOperationManager.h
//  CMM
//
//  Created by qianye on 2017/12/11.
//  Copyright © 2017年 chemanman. All rights reserved.
//

#import "CCHTTPRequestOperation.h"
#import "AFSecurityPolicy.h"
#import "AFNetworkReachabilityManager.h"

@interface CCHTTPRequestOperationManager : NSObject <NSSecureCoding, NSCopying>

@property (readonly, nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) AFHTTPRequestSerializer <AFURLRequestSerialization> * requestSerializer;
@property (nonatomic, strong) AFHTTPResponseSerializer <AFURLResponseSerialization> * responseSerializer;
@property (nonatomic, strong) AFSecurityPolicy *securityPolicy;
@property (readwrite, nonatomic, strong) AFNetworkReachabilityManager *reachabilityManager;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, assign) BOOL shouldUseCredentialStorage;
@property (nonatomic, strong) dispatch_queue_t completionQueue;
@property (nonatomic, strong) dispatch_group_t completionGroup;
@property (nonatomic, strong) NSURLCredential *credential;

// 网络请求延迟时间
@property (nonatomic, assign) NSTimeInterval beforeDelaytimeInterval;
@property (nonatomic, assign) NSTimeInterval afterDelaytimeInterval;

- (instancetype)initWithBaseURL:(NSURL *)url;

- (CCHTTPRequestOperation *)cc_HTTPRequestOperationWithHTTPMethod:(NSString *)method
                                                              URL:(NSString *)URLString
                                                       parameters:(id)parameters
                                                          success:(void (^)(CCHTTPRequestOperation *operation, id responseObject))success
                                                          failure:(void (^)(CCHTTPRequestOperation *operation, NSError *error))failure;

@end
