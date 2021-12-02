//
//  UIGestureRecognizer+SensorsData.m
//  BuriedPointDemo
//
//  Created by LYL on 2021/9/21.
//

#import "UIGestureRecognizer+SensorsData.h"
#import "NSObject+SASwizzler.h"
#import "SensorsAnalyticsSDK.h"

@implementation UIGestureRecognizer (SensorsData)

+ (void)load{
    // 方法交换
    [UIGestureRecognizer sensorsdata_swizzleMethod:@selector(initWithTarget:action:) withMethod:@selector(sensorsdata_initWithTarget:action:)];
    [UIGestureRecognizer sensorsdata_swizzleMethod:@selector(addTarget:action:) withMethod:@selector(sensorsdata_addTarget:action:)];
}

- (instancetype)sensorsdata_initWithTarget:(id)target action:(SEL)action{
    [self sensorsdata_initWithTarget:target action:action];
    
    [self addTarget:target action:action];
    return self;
}

- (void)sensorsdata_addTarget:(id)target action:(SEL)action{
    [self sensorsdata_addTarget:target action:action];
    
    [self sensorsdata_addTarget:self action:@selector(sensorsdata_trackTapGestureAction:)];
}

- (void)sensorsdata_trackTapGestureAction:(UITapGestureRecognizer *)sender {
    UIView *view = sender.view;
    if (![view isKindOfClass:[UILabel class]]) {
        return;
    }
    [[SensorsAnalyticsSDK sharedInstance] trackAppClickWithView:view properties:nil];
}

@end
