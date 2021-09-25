//
//  UIApplication+SensorsData.m
//  BuriedPointDemo
//
//  Created by LYL on 2021/9/13.
//

#import "UIApplication+SensorsData.h"
#import "SensorsAnalyticsSDK.h"
#import "NSObject+SASwizzler.h"

@implementation UIApplication (SensorsData)

+ (void)load{
    [UIApplication sensorsdata_swizzleMethod:@selector(sendAction:to:from:forEvent:) withMethod:@selector(sensorsdata_sendAction:to:from:forEvent:)];
}

- (BOOL)sensorsdata_sendAction:(SEL)action to:(nullable id)target from:(nullable id)sender forEvent:(nullable UIEvent *)event{
    
    [[SensorsAnalyticsSDK sharedInstance] trackAppClickWithView:sender properties:nil];
    return [self sensorsdata_sendAction:action to:target from:sender forEvent:event];;
}


@end
