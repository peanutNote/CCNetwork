//
//  CCHTTPRequestOperation.h
//  CMM
//
//  Created by qianye on 2018/1/6.
//  Copyright © 2018年 chemanman. All rights reserved.
//

#import <AFNetworking.h>

@interface CCHTTPRequestOperation : AFURLConnectionOperation

@property (readonly, nonatomic, strong) NSHTTPURLResponse *response;

@property (nonatomic, strong) AFHTTPResponseSerializer <AFURLResponseSerialization> * responseSerializer;

@property (readonly, nonatomic, strong) id responseObject;

@property (nonatomic, assign) NSTimeInterval afterDelaytimeInterval;

- (void)setCompletionBlockWithSuccess:(void (^)(CCHTTPRequestOperation *operation, id responseObject))success
                              failure:(void (^)(CCHTTPRequestOperation *operation, NSError *error))failure;

@end
