//
//  UIViewController+SensorsData.m
//  BuriedPointDemo
//
//  Created by LYL on 2021/9/13.
//

#import "UIViewController+SensorsData.h"
#import "SensorsAnalyticsSDK.h"
#import "NSObject+SASwizzler.h"

@implementation UIViewController (SensorsData)

+ (void)load{
    
    [UIViewController sensorsdata_swizzleMethod:@selector(viewDidAppear:) withMethod:@selector(sensorsdata_viewDidAppear:)];
}

-(void)sensorsdata_viewDidAppear:(BOOL)animated{
    [self sensorsdata_viewDidAppear:animated];

    NSMutableDictionary *properties=[NSMutableDictionary dictionary];
    [properties setValue:NSStringFromClass([self class]) forKey:@"$screen_name"];
    [[SensorsAnalyticsSDK sharedInstance]track:@"$AppViewScreen"properties:properties];
}

@end
