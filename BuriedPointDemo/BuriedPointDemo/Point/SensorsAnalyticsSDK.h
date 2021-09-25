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


- (void)trackAppClickWithView:(UIView*)view properties:(NSDictionary<NSString*,id>*)properties;

- (void)trackAppClickWithTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath properties:(nullable NSDictionary<NSString *,id> *)properties;

- (void)login:(NSString*)loginId;

@end

NS_ASSUME_NONNULL_END
