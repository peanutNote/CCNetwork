//
//  CCNetworkTools.h
//  CMM
//
//  Created by qianye on 2017/12/13.
//  Copyright © 2017年 chemanman. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - CCNetworkHelper
#pragma mark 网络请求助手
@interface CCNetworkHelper : NSObject
/// 处理特出情况后的请求链接
@property (nonatomic, strong) NSMutableString *url;
/// 拼接base parameters后的入参
@property (nonatomic, strong) NSMutableDictionary *parameters;
/// 上传的图片信息
@property (nonatomic, copy) NSArray *images;
/// 请求超时时间，默认为20s
@property (nonatomic, assign) NSTimeInterval timeoutInterval;
/// 请求之前延迟时间，默认0
@property (nonatomic, assign) NSTimeInterval requestDelayBeforeRefresh;
/// 请求之后延迟时间，默认0
@property (nonatomic, assign) NSTimeInterval requestDelayAfterRefresh;
/// 是否显示加载提示，默认YES
@property (nonatomic, assign) BOOL isShowHUD;
/// 加载提示是否可以交互，默认YES
@property (nonatomic, assign) BOOL IsHUDUserInteractionEnabled;
/// 加载提示文案，默认为：请求稍后...
@property (nonatomic, strong) NSString *networkHUDMessage;
/// 专业版请求模板
@property (nonatomic, strong) NSDictionary *tplDict;

- (NSDictionary *)getReqParameters;
/// 清除所有入参
- (void)clearPatameters;
/// 手动设置请求url，传入的url无效
- (void)setRequestURL:(NSString *)url;
/// 手动设置请求入参并拼接基础参数，传入的入参无效
- (void)setRequestParameters:(NSDictionary *)parameters;
- (BOOL)getCheckUrlResult;
- (BOOL)getCheckParametersResult;

@end

#pragma mark - CCNetworkResponser
#pragma mark 请求回调数据处理

/// 专业版网络请求errno检测
typedef BOOL (^CMCheckErrorNumber)(void);
/// 通用版版网络请求errno检测
typedef BOOL (^MMCheckErrorNumber)(void);

@interface CCNetworkResponser : NSObject

@property (nonatomic, assign) NSInteger status;
@property (nonatomic, readonly) NSString *errmsg;
/// 直接返回的数据
@property (nonatomic, strong, readonly) id responseObj;
/// 解析数据层res
@property (nonatomic, strong, readonly) id res;
/// 解析数据层data
@property (nonatomic, strong, readonly) id data;
/// 专业版返回数据默认监测(status不为0时自动显示错误提示)
@property (nonatomic, copy) CMCheckErrorNumber cmErrno;
/// 通用版返回数据默认监测(status不为0时自动显示错误提示)
@property (nonatomic, copy) MMCheckErrorNumber mmErrno;

- (void)setCheckParamsFailInfo;
- (void)setCheckURLFailInfo;
- (void)setNetworkError:(NSError *)error;

- (void)setResponserInitWithData:(NSDictionary *)responseDict;
- (void)setSpecialCustomDeal:(id)responseObject;

@end

#pragma mark - CCNetworkComber
#pragma mark 请求参数拼接

#define cmp_nil       @"qaz_CCMakeParameterNil"         // nil标示
#define cmp_dic       @"qaz_CCMakeParameterDictionary"  // vaue是字典标示
#define cmp_array     @"qaz_CCMakeParameterArray"       // value是数组标示

@interface CCNetworkComber : NSObject

@property (nonatomic, strong) NSMutableArray *parameters;

- (void)cc_makeParameter:(id)superKey key:(id)key value:(id)value;

@end

#pragma mark - CCNetworkTools
#pragma mark - 请求工具

/**
 请求成功回调block

 @param responser 参考CCNetworkResponser使用说明
 */
typedef void (^ResponserBlock)(CCNetworkResponser *responser);

/**
 请求前处理的助手block

 @param helper 参考CCNetworkHelper使用说明
 */
typedef void (^HelperBlock)(CCNetworkHelper *helper);

/**
 拼接参数使用的block
 
 @param comber 参考CCNetworkComber使用说明
 */
typedef void (^CombiationParameters)(CCNetworkComber *comber);

#define kNetworkErrorno         (-9528)
#define kNetworkErrorMessage    @"网络请求异常，请重新尝试"

@interface CCNetworkTools : NSObject

/// 获取网络请求Base URL
+ (NSURL *)getBaseURL;

/// 处理并且拼接基础请求参数
+ (NSDictionary *)getHandelRequestParams:(NSDictionary *)params;

/// 获取请求Base Params
+ (NSMutableDictionary *)baseParameter;

/// 拼接请求入参
+ (NSDictionary *)createDictWithComber:(CombiationParameters)comber;

+ (void)showHudWith:(CCNetworkHelper *)helper;

+ (void)dismissHUDWith:(CCNetworkHelper *)helper;

@end
