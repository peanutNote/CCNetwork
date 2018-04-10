#  CCNetwrok使用说明

### 快速入手
```objc
// 极简模式
[CCNetwork postWithURL:@"" params:nil responserBlock:^(CCNetworkResponser *responser) {
    if (responser.cmErrno()) {
        // do after success
}
}];

// 网络请求加载提示
[CCNetwork postWithURL:@"" params:nil helperBlock:^(CCNetworkHelper *helper) {
    // 不显示网络请求加载提示，默认是YES
    helper.isShowHUD = NO;
    // 网络请求加载提示禁止交互，默认是YES
    helper.IsHUDUserInteractionEnabled = NO;
    // 网络请求加载提示文案，默认是：请稍后...
    helper.networkHUDMessage = @"正在发送请求...";
} responserBlock:^(CCNetworkResponser *responser) {
    if (responser.cmErrno()) {
        // do after success
}
}];

// 请求延迟、超时设置
[CCNetwork postWithURL:@"" params:nil helperBlock:^(CCNetworkHelper *helper) {
    // 网络请求超时时间，默认是：20s
    helper.timeoutInterval = 10.0;
    // 网络请求前的延迟时间，默认是为：0s
    helper.requestDelayBeforeRefresh = 2.0;
    // 网络请求后的延迟时间，默认是为：0s
    helper.requestDelayAfterRefresh = 2.0;
} responserBlock:^(CCNetworkResponser *responser) {
    if (responser.cmErrno()) {
        // do after success
}
}];

// 请求入参控制
[CCNetwork postWithURL:@"" params:nil helperBlock:^(CCNetworkHelper *helper) {
    // 网络请求自定义参数，默认添加了基础入参
    [helper clearPatameters];
    [helper.parameters setObject:@"OOO" forKey:@"XXX"];
    // 网络请求添加模板，默认为raw : @"1"
    helper.tplDict = @{@"tpl" : @"app"};
    // 网络请求不使用模板
    helper.tplDict = nil;
} responserBlock:^(CCNetworkResponser *responser) {
    if (responser.cmErrno()) {
        // do after success
}
}];
```

### 精简进阶
1、关于请求URL

* 只允许传NSString字符串，且不能为空
* 如果是开发环境需要在CCNetworkURL中定义时，在末尾加上___debug，这样在不知情的情况下，切换到线上环境时该请求会被终止，避免出现error_trace，返回错误码：-9527，错误原因：请求URL检测错误

2、关于请求入参

* 可以使用helper方法clearPatameters，清除所有请求参数，该设置级别最高
* 不论请求参数传入什么(包括nil)，parameters会拼接完对应基础入参(通用版与专业版有所不同)后传入helper，网络请求代码处可以通过helper随时修改该入参
* tplDict携带了模板参数，默认被赋值为@{@"raw" : @"1"}，如果需要修改需要重新赋值，如果不需要模板需要手动置为nil
* 请求入参可以使用CCNetworkComber进行拼接，具体使用如下：

```
// 字典：
@{
    @"person" : @{
    @"name" : @"jack"
    @"friends" : @[
        @{@"name" : @"rose"},
        @{@"name" : @"mitch"}
        ]
    }
    @"animal" : @"dog"
}

// 使用CCNetworkComber创建的代码如下：
NSDictionary *params = [CCNetworkTools createDictWithComber:^(CCNetworkComber *comber) {
    [comber cc_makeParameter:cmp_nil key:@"person" value:cmp_dic];
    [comber cc_makeParameter:@"person" key:@"name" value:@"jack"];
    [comber cc_makeParameter:@"person" key:@"friends" value:cmp_array];
    NSDictionary *friend1 = [CCNetworkTools createDictWithComber:^(CCNetworkComber *comber) {
    [comber cc_makeParameter:cmp_nil key:@"name" value:@"rose"];
    }];
    NSDictionary *friend2 = [CCNetworkTools createDictWithComber:^(CCNetworkComber *comber) {
    [comber cc_makeParameter:cmp_nil key:@"name" value:@"mitch"];
    }];
    [comber cc_makeParameter:@"friends" key:cmp_nil value:friend1];
    [comber cc_makeParameter:@"friends" key:cmp_nil value:friend2];
    [comber cc_makeParameter:cmp_nil key:@"animal" value:@"dog"];
}];
```

3、关于请求回调

* 可使用responser的cmerror()(专业版，当返回的errno不为0是返回NO，并弹错误提示)或者mmerror()(通用版，当返回的errno不为0是返回NO，并弹错误提示)，快速进行返回结果检测。
* 当返回的数据包含在res中时，可以从responser.res中获取；当返回的数据包含在data中时，可以从responser.data中获取；原始返回数据可以从responser.resposeObj中获取
* responser.status为-1001时为网络请求超时

