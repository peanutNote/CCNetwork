//
//  CCNetwork.m
//  CMM
//
//  Created by qianye on 2017/12/9.
//  Copyright © 2017年 chemanman. All rights reserved.
//

#import "CCNetwork.h"
#import "CCHTTPRequestOperationManager.h"
#import "CCModelDefine.h"

typedef void (^RequestSuccessBlock) (CCHTTPRequestOperation *operation, id responseObject);
typedef void (^RequestFailBlock) (CCHTTPRequestOperation *operation, NSError *error);

@implementation CCNetwork

+ (CCHTTPRequestOperation *)getWithURL:(NSString *)url params:(NSDictionary *)params responserBlock:(ResponserBlock)responserBlock {
    return [CCNetwork getWithURL:url params:params helperBlock:NULL responserBlock:responserBlock];
}
+ (CCHTTPRequestOperation *)getWithURL:(NSString *)url params:(NSDictionary *)params helperBlock:(HelperBlock)helperBlock responserBlock:(ResponserBlock)responserBlock;
{
    return [CCNetwork requestWithMethod:@"GET" URL:url params:params helperBlock:helperBlock responserBlock:responserBlock];
}

+ (CCHTTPRequestOperation *)postWithURL:(NSString *)url params:(NSDictionary *)params responserBlock:(ResponserBlock)responserBlock {
    return [CCNetwork postWithURL:url params:params helperBlock:NULL responserBlock:responserBlock];
}
+ (CCHTTPRequestOperation *)postWithURL:(NSString *)url params:(NSDictionary *)params helperBlock:(HelperBlock)helperBlock responserBlock:(ResponserBlock)responserBlock;
{
    return [CCNetwork requestWithMethod:@"POST" URL:url params:params helperBlock:helperBlock responserBlock:responserBlock];
}

+ (CCHTTPRequestOperation *)requestWithMethod:(NSString *)method URL:(NSString *)url params:(NSDictionary *)params helperBlock:(HelperBlock)helperBlock responserBlock:(ResponserBlock)responserBlock;
{
    CCNetworkResponser *responser = [[CCNetworkResponser alloc] init];
    CCNetworkHelper *helper = [[CCNetworkHelper alloc] init];
    [helper setRequestURL:url];
    [helper setRequestParameters:params];
    if (helperBlock) {
        helperBlock(helper);
    }
    if (![helper getCheckUrlResult]) {
        [responser setCheckURLFailInfo];
        if (responserBlock) {
            responserBlock(responser);
        }
        return nil;
    }
    if (![helper getCheckParametersResult]) {
        [responser setCheckParamsFailInfo];
        if (responserBlock) {
            responserBlock(responser);
        }
        return nil;
    }
    // 网络加载提示
    [CCNetworkTools showHudWith:helper];
    // 创建网络请求
    CCHTTPRequestOperationManager *manage = [[CCHTTPRequestOperationManager alloc] initWithBaseURL:[CCNetworkTools getBaseURL]];
    [manage.requestSerializer setTimeoutInterval:helper.timeoutInterval];
    manage.beforeDelaytimeInterval = helper.requestDelayBeforeRefresh;
    manage.afterDelaytimeInterval = helper.requestDelayAfterRefresh;
    manage.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    if (helper.images.count) {
        
    } else {
        
    }
    // 请求成功回调
    RequestSuccessBlock successBlock = ^(CCHTTPRequestOperation *operation, id responseObject) {
        [CCNetworkTools dismissHUDWith:helper];
        NSError *error = nil;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error];
        if (responserBlock) {
            NSDictionary *resultDict = CheckDictionary(responseDict, NO);
            if (resultDict.count) {
                [responser setResponserInitWithData:resultDict];
            } else {
                [responser setSpecialCustomDeal:responseObject];
            }
            if (responserBlock) {
                responserBlock(responser);
            }
        }
    };
    // 请求失败回调
    RequestFailBlock failBlock = ^(CCHTTPRequestOperation *operation, NSError *error) {
        [CCNetworkTools dismissHUDWith:helper];
        [responser setNetworkError:error];
        if (responserBlock) {
            responserBlock(responser);
        }
    };
    
    return [manage cc_HTTPRequestOperationWithHTTPMethod:method URL:helper.url parameters:[helper getReqParameters] success:successBlock failure:failBlock];
}

@end
