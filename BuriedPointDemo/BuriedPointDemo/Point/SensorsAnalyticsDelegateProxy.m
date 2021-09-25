//
//  SensorsAnalyticsDelegateProxy.m
//  BuriedPointDemo
//
//  Created by LYL on 2021/9/14.
//

#import "SensorsAnalyticsDelegateProxy.h"
#import "SensorsAnalyticsSDK.h"

@interface SensorsAnalyticsDelegateProxy ()

@property (nonatomic, weak) id delegate;

@end

@implementation SensorsAnalyticsDelegateProxy

#pragma mark - Life Cycle

#pragma mark - Setters

#pragma mark - Override

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    // 返回delegate对象中对应的方法签名
    return [(NSObject *)self.delegate methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation { // 先执行delegate对象中的方法
    [invocation invokeWithTarget:self.delegate];
//     判断是否是cell的点击事件的代理方法
    if (invocation.selector == @selector(tableView:didSelectRowAtIndexPath:)) {
        // 将方法修改为进行数据采集的方法，即本类中的实例方法：sensorsdata_tableView:did- SelectRowAtIndexPath:
        invocation.selector = NSSelectorFromString(@"sensorsdata_tableView:didSelectRowAtIndexPath:");
        // 执行数据采集相关的方法
        [invocation invokeWithTarget:self];
    }
}

#pragma mark - Public SEL

+ (instancetype)proxyWithTableViewDelegate:(id<UITableViewDelegate>)delegate{
    SensorsAnalyticsDelegateProxy *proxy = [SensorsAnalyticsDelegateProxy alloc];
    proxy.delegate = delegate;
    return proxy;
}

#pragma mark - Private SEL

- (void)sensorsdata_tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [[SensorsAnalyticsSDK sharedInstance] trackAppClickWithTableView:tableView didSelectRowAtIndexPath:indexPath properties:nil];
}

#pragma mark - Protocol Conform

#pragma mark - Getters

@end
