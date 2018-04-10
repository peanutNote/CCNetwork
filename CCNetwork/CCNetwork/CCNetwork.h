//
//  CCNetwork.h
//  CMM
//
//  Created by qianye on 2017/12/9.
//  Copyright © 2017年 chemanman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCNetworkTools.h"
@class CCHTTPRequestOperation;

@interface CCNetwork : NSObject

/**
 发送GET请求，支持自定义helper请求配置

 @param url 请求url（BaseURL 已经集成）
 @param params 请求参数，推荐使用CombiationParameters创建请求入参
 @param helperBlock 自定义检测block回调，具体参考wiki说明文档
 @param responserBlock 请求成功回调（CCNetworkResponser对象包含返回数据，具体参数参考wiki说明文档）
 @return 请求Operation，用于请求并发执行
 */
+ (CCHTTPRequestOperation *)getWithURL:(NSString *)url params:(NSDictionary *)params helperBlock:(HelperBlock)helperBlock responserBlock:(ResponserBlock)responserBlock;
/**
 发送GET请求，使用默认helper请求配置
 */
+ (CCHTTPRequestOperation *)getWithURL:(NSString *)url params:(NSDictionary *)params responserBlock:(ResponserBlock)responserBlock;

/**
 发送POST请求，支持自定义helper请求配置
 
 @param 参考GET入参说明
 */
+ (CCHTTPRequestOperation *)postWithURL:(NSString *)url params:(NSDictionary *)params helperBlock:(HelperBlock)helperBlock responserBlock:(ResponserBlock)responserBlock;
/**
 发送POST请求，使用默认helper请求配置
 
 @param 参考GET入参说明
 */
+ (CCHTTPRequestOperation *)postWithURL:(NSString *)url params:(NSDictionary *)params responserBlock:(ResponserBlock)responserBlock;

@end
