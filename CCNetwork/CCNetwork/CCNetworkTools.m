//
//  CCNetworkTools.m
//  CMM
//
//  Created by qianye on 2017/12/13.
//  Copyright © 2017年 chemanman. All rights reserved.
//

#import "CCNetworkTools.h"
#import "JSONKit.h"
#import <SVProgressHUD.h>
#import "AppDelegate.h"
#import "CCModelDefine.h"

#pragma mark - CCNetworkHelper
#pragma mark 网络请求助手
@implementation CCNetworkHelper

- (instancetype)init {
    if (self = [super init]) {
        [self defaultInitHelper];
    }
    return self;
}

- (void)defaultInitHelper {
    self.timeoutInterval = 20.0;
    self.requestDelayBeforeRefresh = 0.0;
    self.requestDelayAfterRefresh = 0.0;
    self.isShowHUD = YES;
    self.IsHUDUserInteractionEnabled = YES;
    self.networkHUDMessage = @"请稍后...";
    self.tplDict = @{@"raw" : @"1"};
}

- (NSDictionary *)getReqParameters {
    NSMutableDictionary *reqParameters = [NSMutableDictionary dictionary];
    for (NSString *key in _parameters) {
        id value = _parameters[key];
        if ([value isKindOfClass:NSArray.class] || [value isKindOfClass:NSDictionary.class]) {
            NSString *obj = [value JSONString];
            if (obj.length) {
                [reqParameters setObject:[value JSONString] forKey:key];
            }
        } else {
            [reqParameters setObject:value forKey:key];
        }
    }
    return reqParameters;
}

- (void)setRequestURL:(NSString *)url {
    if ([url isKindOfClass:NSString.class] && url.length) {
        _url = url.mutableCopy;
    }
}
- (void)setRequestParameters:(NSDictionary *)parameters {
    _parameters = [CCNetworkTools getHandelRequestParams:parameters].mutableCopy;
}

- (BOOL)getCheckUrlResult {
    if (self.url) {
        if (![self.url isKindOfClass:NSString.class] || self.url.length == 0) {
            return NO;
        }
    }
    return YES;
}
- (BOOL)getCheckParametersResult {
    if (_parameters) {
        if (self.tplDict && self.tplDict.count) {
            [_parameters addEntriesFromDictionary:self.tplDict];
        }
    }
    return YES;
}

- (void)clearPatameters {
    _parameters = nil;
}

@end

#pragma mark - CCNetworkResponser
#pragma mark 请求回调数据处理

@implementation CCNetworkResponser

- (instancetype)init {
    if (self = [super init]) {
        __weak typeof(self) weakSelf = self;
        _cmErrno = ^ {
            if (weakSelf.status != 0) {
                [SVProgressHUD showErrorWithStatus:weakSelf.errmsg];
                return NO;
            }
            return YES;
        };
        _mmErrno = ^ {
            return YES;
        };
    }
    return self;
}

- (void)setCheckParamsFailInfo {
    _status = -9527;
    _errmsg = @"请求参数检测错误";
}
- (void)setCheckURLFailInfo {
    _status = -9527;
    _errmsg = @"请求URL检测错误";
}

- (void)setNetworkError:(NSError *)error {
    if (error.code == -1001) {
        // 网络请求超时
        _status = -1001;
        _errmsg = @"网络请求超时";
    } else {
        _status = kNetworkErrorno;
        _errmsg = kNetworkErrorMessage;
    }
}

- (void)setResponserInitWithData:(NSDictionary *)responseDict {
    _responseObj = responseDict;
    
    id res = [responseDict objectForKey:@"res"];
    id data = [responseDict objectForKey:@"data"];
    if (res) {
        _status = [[responseDict objectForKey:@"errno"] integerValue];
        _errmsg = GetValueFromDict(responseDict, @"errmsg", _is_string);
        if (_status == 0) {
            if ([res isKindOfClass:NSDictionary.class] || [res isKindOfClass:NSArray.class]) {
                _res = res;
            }
        } else {
            if (_status == -1) {
                _errmsg = @"请重新登录";
            } else {
                if ([res isKindOfClass:NSDictionary.class] || [res isKindOfClass:NSArray.class]) {
                    _res = res;
                }
            }
        }
    } else if (data) {
        _status = [[responseDict objectForKey:@"code"] integerValue];
        _errmsg = GetValueFromDict(responseDict, @"msg", _is_string, @"返回数据异常");
        if ([data isKindOfClass:NSDictionary.class] || [data isKindOfClass:NSArray.class]) {
            _data = data;
        }
        return;
    }
}

- (void)setSpecialCustomDeal:(id)responseObject {
    _responseObj = responseObject;
    _status = -9525;
    _errmsg = @"特殊数据，需要手动解析";
}

@end

#pragma mark - CCNetworkComber
#pragma mark 请求参数拼接

@implementation CCNetworkComber

- (instancetype)init {
    if (self = [super init]) {
        _parameters = [NSMutableArray array];
    }
    return self;
}

- (void)cc_makeParameter:(id)superKey key:(id)key value:(id)value {
    NSMutableArray *tempArray = NSMutableArray.new;
    if (superKey != nil && key != nil && value != nil) {
        [tempArray addObject:superKey];
        [tempArray addObject:key];
        [tempArray addObject:value];
    }
    [_parameters addObject:tempArray];
}

@end

#pragma mark - CCNetworkTools
#pragma mark - 请求工具

@implementation CCNetworkTools

+ (NSDictionary *)getHandelRequestParams:(NSDictionary *)params
{
    NSMutableDictionary *baseParams = [self baseParameter];
    if (params.count == 0) {
        return @{
                 @"app_info" : baseParams,
                 };
    } else {
        return @{
                 @"req" : params,
                 @"app_info" : baseParams,
                 };
    }
}

+ (NSURL *)getBaseURL
{
    return [NSURL URLWithString:@"www"];
}

+ (NSMutableDictionary *)baseParameter
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@"ios" forKey:@"os_type"];
    [parameters setObject:@"mobile" forKey:@"from"];
    return parameters;
}

+ (NSDictionary *)createDictWithComber:(CombiationParameters)comber
{
    if (comber) {
        CCNetworkComber *networkComber = [[CCNetworkComber alloc] init];
        comber(networkComber);
        NSMutableDictionary *parameters = NSMutableDictionary.new;
        for (NSArray *array in networkComber.parameters) {
            if ([array isKindOfClass:NSArray.class] && array.count == 3) {
                NSString *superKey = [array firstObject];
                NSString *key = [array objectAtIndex:1];
                id value = [array lastObject];
                if ([self isSpecialNil:superKey]) {
                    if ([self isSpecialDic:value]) {
                        [parameters setObject:NSMutableDictionary.new forKey:key];
                    } else if ([self isSpecialArray:value]) {
                        [parameters setObject:NSMutableArray.new forKey:key];
                    } else if (![self isSpecialNil:value]) {
                        [parameters setObject:value forKey:key];
                    }
                } else {
                    id obj = [self findValueFromDictionary:parameters withKey:superKey];
                    if ([obj isKindOfClass:NSMutableArray.class]) {
                        if (![CCNetworkTools isSpecialKey:value]) {
                            [(NSMutableArray *)obj addObject:value];
                        }
                    } else if ([obj isKindOfClass:NSMutableDictionary.class]) {
                        if (![CCNetworkTools isSpecialKey:key]) {
                            if (![CCNetworkTools isSpecialKey:value]) {
                                [(NSMutableDictionary *)obj setObject:value forKey:key];
                            } else {
                                if ([self isSpecialDic:value]) {
                                    [(NSMutableDictionary *)obj setObject:NSMutableDictionary.new forKey:key];
                                } else if ([self isSpecialArray:value]) {
                                    [(NSMutableDictionary *)obj setObject:NSMutableArray.new forKey:key];
                                }
                            }
                        }
                    }
                }
            }
        }
        return parameters;
    }
    return NSDictionary.new;
}

+ (BOOL)isSpecialKey:(id)key
{
    if ([key isKindOfClass:NSString.class]) {
        if ([key isEqualToString:cmp_nil] || [key isEqualToString:cmp_dic] || [key isEqualToString:cmp_array]) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)isSpecialNil:(id)value
{
    return [value isKindOfClass:NSString.class] && [value isEqualToString:cmp_nil];
}

+ (BOOL)isSpecialDic:(id)value
{
    return [value isKindOfClass:NSString.class] && [value isEqualToString:cmp_dic];
}

+ (BOOL)isSpecialArray:(id)value
{
    return [value isKindOfClass:NSString.class] && [value isEqualToString:cmp_array];
}

+ (id)findValueFromDictionary:(NSDictionary *)dictionary withKey:(NSString *)key
{
    for (NSString *innerKey in dictionary) {
        if ([innerKey isEqualToString:key]) {
            return dictionary[innerKey];
        } else {
            id value = dictionary[innerKey];
            if ([value isKindOfClass:NSMutableDictionary.class]) {
                return [self findValueFromDictionary:value withKey:key];
            } else if ([value isKindOfClass:NSMutableArray.class]) {
                return value;
            }
        }
    }
    return nil;
}

+ (void)showHudWith:(CCNetworkHelper *)helper {
    if (helper.isShowHUD) {
        AppDelegate *appDelegate = (AppDelegate *)UIApplication.sharedApplication.delegate;
        UIView *showView = appDelegate.window;
        if (appDelegate.window.rootViewController) {
            showView = appDelegate.window.rootViewController.view;
            if ([appDelegate.window.rootViewController isKindOfClass:UITabBarController.class]) {
                UITabBarController *mainTab = (UITabBarController *)appDelegate.window.rootViewController;
                showView = mainTab.selectedViewController.view;
                if ([mainTab.selectedViewController isKindOfClass:UINavigationController.class]) {
                    UINavigationController *mainNav = mainTab.selectedViewController;
                    showView = mainNav.topViewController.view;
                }
            }
        }
        [SVProgressHUD showErrorWithStatus:helper.networkHUDMessage];
    }
}

+ (void)dismissHUDWith:(CCNetworkHelper *)helper {
    if (helper.isShowHUD) {
        [SVProgressHUD dismiss];
    }
}

@end
