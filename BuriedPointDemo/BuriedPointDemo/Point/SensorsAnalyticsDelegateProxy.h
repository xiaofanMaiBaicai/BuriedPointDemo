//
//  SensorsAnalyticsDelegateProxy.h
//  BuriedPointDemo
//
//  Created by LYL on 2021/9/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SensorsAnalyticsDelegateProxy : NSProxy <UITableViewDelegate>

+ (instancetype)proxyWithTableViewDelegate:(id<UITableViewDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
