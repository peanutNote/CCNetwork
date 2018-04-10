//
//  CCHTTPRequestOperationManager.m
//  CMM
//
//  Created by qianye on 2017/12/11.
//  Copyright © 2017年 chemanman. All rights reserved.
//

#import "CCHTTPRequestOperationManager.h"
#import "CCModelDefine.h"

@interface CCHTTPRequestOperationManager ()
@property (readwrite, nonatomic, strong) NSURL *baseURL;
@end

@implementation CCHTTPRequestOperationManager

- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // Ensure terminal slash for baseURL path, so that NSURL +URLWithString:relativeToURL: works as expected
    if ([[url path] length] > 0 && ![[url absoluteString] hasSuffix:@"/"]) {
        url = [url URLByAppendingPathComponent:@""];
    }
    
    self.baseURL = url;
    
    self.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    
    self.securityPolicy = [AFSecurityPolicy defaultPolicy];
    
    self.reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    
    self.operationQueue = [[NSOperationQueue alloc] init];
    
    self.shouldUseCredentialStorage = YES;
    
    return self;
}

- (void)setRequestSerializer:(AFHTTPRequestSerializer <AFURLRequestSerialization> *)requestSerializer {
    NSParameterAssert(requestSerializer);
    
    _requestSerializer = requestSerializer;
}

- (void)setResponseSerializer:(AFHTTPResponseSerializer <AFURLResponseSerialization> *)responseSerializer {
    NSParameterAssert(responseSerializer);
    
    _responseSerializer = responseSerializer;
}

- (CCHTTPRequestOperation *)cc_HTTPRequestOperationWithHTTPMethod:(NSString *)method
                                                              URL:(NSString *)URLString
                                                       parameters:(id)parameters
                                                          success:(void (^)(CCHTTPRequestOperation *operation, id responseObject))success
                                                          failure:(void (^)(CCHTTPRequestOperation *operation, NSError *error))failure {
    CCHTTPRequestOperation *requestOperation = [self cc_HTTPRequestOperationWithHTTPMethod:CheckString(method, YES, @"POST") URLString:URLString parameters:parameters success:success failure:failure];
    requestOperation.afterDelaytimeInterval = self.afterDelaytimeInterval;
    if (_beforeDelaytimeInterval > 0.1) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_beforeDelaytimeInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.operationQueue addOperation:requestOperation];
        });
    } else {
        [self.operationQueue addOperation:requestOperation];
    }
    return requestOperation;
}

- (CCHTTPRequestOperation *)cc_HTTPRequestOperationWithHTTPMethod:(NSString *)method
                                                     URLString:(NSString *)URLString
                                                    parameters:(id)parameters
                                                       success:(void (^)(CCHTTPRequestOperation *operation, id responseObject))success
                                                       failure:(void (^)(CCHTTPRequestOperation *operation, NSError *error))failure
{
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:&serializationError];
    if (serializationError) {
        if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
#pragma clang diagnostic pop
        }
        
        return nil;
    }
    
    CCHTTPRequestOperation *operation = [[CCHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = self.responseSerializer;
    operation.shouldUseCredentialStorage = self.shouldUseCredentialStorage;
    operation.credential = self.credential;
    operation.securityPolicy = self.securityPolicy;
    
    [operation setCompletionBlockWithSuccess:success failure:failure];
    operation.completionQueue = self.completionQueue;
    operation.completionGroup = self.completionGroup;
    
    return operation;
}

#pragma mark - NSObject

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, baseURL: %@, operationQueue: %@>", NSStringFromClass([self class]), self, [self.baseURL absoluteString], self.operationQueue];
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeObject:self.baseURL forKey:NSStringFromSelector(@selector(baseURL))];
    [aCoder encodeObject:self.requestSerializer forKey:NSStringFromSelector(@selector(requestSerializer))];
    [aCoder encodeObject:self.responseSerializer forKey:NSStringFromSelector(@selector(responseSerializer))];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    NSURL *baseURL = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(baseURL))];
    
    self = [self initWithBaseURL:baseURL];
    if (!self) {
        return nil;
    }
    
    self.requestSerializer = [aDecoder decodeObjectOfClass:[AFHTTPRequestSerializer class] forKey:NSStringFromSelector(@selector(requestSerializer))];
    self.responseSerializer = [aDecoder decodeObjectOfClass:[AFHTTPResponseSerializer class] forKey:NSStringFromSelector(@selector(responseSerializer))];
    
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    CCHTTPRequestOperationManager *HTTPClient = [[[self class] allocWithZone:zone] initWithBaseURL:self.baseURL];
    
    HTTPClient.requestSerializer = [self.requestSerializer copyWithZone:zone];
    HTTPClient.responseSerializer = [self.responseSerializer copyWithZone:zone];
    
    return HTTPClient;
}

@end
