//
//  UITableView+SensorsData.h
//  BuriedPointDemo
//
//  Created by LYL on 2021/9/14.
//

#import <UIKit/UIKit.h>
#import "SensorsAnalyticsDelegateProxy.h"

NS_ASSUME_NONNULL_BEGIN

@interface UITableView (SensorsData)

@property (nonatomic, strong) SensorsAnalyticsDelegateProxy *sensorsdata_delegateProxy;

@end

NS_ASSUME_NONNULL_END
