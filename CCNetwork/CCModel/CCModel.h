//
//  CCModel.h
//  CMM
//
//  Created by qianye on 17/5/17.
//  Copyright © 2017年 zuozheng. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - Property Protocols
/**
 * 模型解析时会忽略该属性
 */
@protocol CCIgnore
@end

/**
 * 当Model中的属性名在json中不存在时ignore，否则会取默认值已确保数据安全
 */
@protocol CCNilWhenNull
@end

/**
 标记该属性名相对json中的key是否采用了驼峰命名方式，此优先级低于CCKeyMapper中的映射关系
 */
@protocol CCCamelCase
@end

@interface NSObject (CCModelPropertyCompatibility) <CCIgnore, CCNilWhenNull, CCCamelCase>

@end


@interface CCModel : NSObject

/**
 重新确定映射关系，健值对书写为 json中key : model中属性名，其中json中key支持多级取值如：@"info.name[0][1]"
 */
- (NSDictionary *)CCKeyMapper;

/**
 CCModel唯一创建方法

 @param dictionary json数据
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end


/// CCModel 扩展
@interface CCModel (CCModelExtensionMethods)

#define CCModelCombinationDict(completeDict) {va_list firstList; va_start(firstList, dictionary); \
        if(dictionary) { [completeDict addEntriesFromDictionary:dictionary]; \
            NSDictionary *arg; while ((arg = va_arg(firstList, NSDictionary *))) { \
                [completeDict addEntriesFromDictionary:arg]; } \
            va_end(firstList); }}

/// 将模型转变成对应字典
- (NSDictionary *)toDictionary;

/**
 CCModel创建扩展方法

 @param dictionary 支持传多个json
 */
- (instancetype)initWithDictionarys:(NSDictionary *)dictionary, ... NS_REQUIRES_NIL_TERMINATION;

/**
 初始化Model各属性字段默认值
 */
- (void)setDefaultValue;

@end
