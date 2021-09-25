//
//  UITableView+SensorsData.m
//  BuriedPointDemo
//
//  Created by LYL on 2021/9/14.
//

#import "UITableView+SensorsData.h"
#import"NSObject+SASwizzler.h"
#import<objc/message.h>
#import "SensorsAnalyticsSDK.h"


@implementation UITableView (SensorsData)

+ (void)load{
    [UITableView sensorsdata_swizzleMethod:@selector(setDelegate:) withMethod:@selector(sensorsdata_setDelegate:)];
}

- (void)sensorsdata_setDelegate:(id<UITableViewDelegate>)delegate{
    
    self.sensorsdata_delegateProxy = nil;
    if (delegate) {
        SensorsAnalyticsDelegateProxy *proxy = [SensorsAnalyticsDelegateProxy proxyWithTableViewDelegate:delegate];
        self.sensorsdata_delegateProxy = proxy;
        [self sensorsdata_setDelegate:proxy];
    } else {
        [self sensorsdata_setDelegate:nil];
    }
    
//    [self sensorsdata_swizzleDidSelectRowAtIndexPathMethodWithDelegate:delegate];
}

static void sensorsdata_tableViewDidSelectRow(id object, SEL selctor , UITableView *tableView , NSIndexPath *indexPath){
    SEL selector = NSSelectorFromString(@"sensorsdata_tableView:didSelectRowAtIndexPath:");
        // 调用原始的 -tableVIew:didSelectRowAtIndexPath: 方法实现
    ((void(*)(id, SEL, id, id))objc_msgSend)(object, selector, tableView, indexPath);
    
    [[SensorsAnalyticsSDK sharedInstance] trackAppClickWithTableView:tableView didSelectRowAtIndexPath:indexPath properties:@{}];
}

// 获取delegate对象的类
- (void)sensorsdata_swizzleDidSelectRowAtIndexPathMethodWithDelegate:(id)delegate {
    Class delegateClass = [delegate class];
    
    // 当delegate 对象中没有实现tableView:didSelectRowAtIndexPath: 方法时，直接返回
    SEL sourceSelector = @selector(tableView:didSelectRowAtIndexPath:);
    if (![delegate respondsToSelector:sourceSelector]) {
        return;
    }
    
    //  当delegate对象中已经存在了sensorsdata_tableView:didSelectRowAtIndexPath:方法， 说明已经进行交换，因此可以直接返回
    SEL destinationSelector = NSSelectorFromString(@"sensorsdata_tableView:didSelectRowAtIndexPath:");
    if ([delegate respondsToSelector:destinationSelector]) {
        return;
    }
    
    Method sourceMethod = class_getInstanceMethod(delegateClass, sourceSelector);
    const char * encoding = method_getTypeEncoding(sourceMethod);
    
    // 新增方法
    if (!class_addMethod([delegate class], destinationSelector, (IMP)sensorsdata_tableViewDidSelectRow, encoding)){
        
        return;
    }
    
    [delegateClass sensorsdata_swizzleMethod:sourceSelector withMethod:destinationSelector];
}

- (void)setSensorsdata_delegateProxy:(SensorsAnalyticsDelegateProxy *)sensorsdata_delegateProxy{
    objc_setAssociatedObject(self, @selector(setSensorsdata_delegateProxy:), sensorsdata_delegateProxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SensorsAnalyticsDelegateProxy *)sensorsdata_delegateProxy {
    return objc_getAssociatedObject(self, @selector(sensorsdata_delegateProxy));
}
@end
