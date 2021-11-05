//
//  SensorsAnalyticsSDK.h
//  BuriedPointDemo
//
//  Created by LYL on 2021/9/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SensorsAnalyticsSDK : NSObject

@property (nonatomic, copy) NSString *deviceId;

+(SensorsAnalyticsSDK*)sharedInstance;

- (void)track:(NSString *)eventName properties:(nullable NSDictionary<NSString *,id> *)properties;


/// 支持UITableView触发$AppClick事件
/// @param tableView 触发事件的UITableView视图
/// @param indexPath 在UITableView中点击的位置
/// @param properties 自定义事件属性
- (void)trackAppClickWithTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath properties:(nullable NSDictionary<NSString *,id> *)properties;


//触发$AppClick事件
//@param view 触发事件的控件
//@param properties自定义事件属性

- (void)trackAppClickWithView:(UIView*)view properties:(NSDictionary<NSString*,id>*)properties;


// 开始计时
- (void)trackTimerStart:(NSString *)eventName;

// 停止计时
- (void)trackTimerEnd:(NSString *)eventName properties:(nullable NSDictionary<NSString *,id> *)properties;

// 用户登录标识
- (void)login:(NSString*)loginId;

@end

NS_ASSUME_NONNULL_END
