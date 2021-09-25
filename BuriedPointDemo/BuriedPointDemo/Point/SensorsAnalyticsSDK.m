//
//  SensorsAnalyticsSDK.m
//  BuriedPointDemo
//
//  Created by LYL on 2021/9/13.
//

#import "SensorsAnalyticsSDK.h"
#import "UIView+SensorsData.h"
#import <AdSupport/AdSupport.h>
#import "SensorsAnalyticsFileStore.h"
#import "SensorsAnalyticsExceptionHandler.h"

@interface SensorsAnalyticsSDK ()

// 默认属性
@property (nonatomic, strong) NSDictionary <NSString *, id> *automaticProperties;

@property (nonatomic, copy) NSString *loginId;

@property (nonatomic, strong) SensorsAnalyticsFileStore *fileStore;

@end

@implementation SensorsAnalyticsSDK {
    NSString *_deviceId;
}

+(SensorsAnalyticsSDK*)sharedInstance{
    static dispatch_once_t onceToken;
    static SensorsAnalyticsSDK *sdk = nil;
    dispatch_once(&onceToken,^{
        sdk = [[SensorsAnalyticsSDK alloc] init];
    });
    return sdk;
}

- (instancetype)init{
    if (self = [super init]) {
        _automaticProperties = [self collectAutomaticProperties];
        _loginId = [[NSUserDefaults standardUserDefaults] objectForKey:@"SensorsAnaly-ticsLoginId"];
        _fileStore = [[SensorsAnalyticsFileStore alloc]init];
        [SensorsAnalyticsExceptionHandler sharedInstance];
    }
    return self;
}

#pragma mark - Life Cycle

#pragma mark - Setters

- (void)setDeviceId:(NSString *)deviceId{
    _deviceId = deviceId;
    [self saveDeviceId:deviceId];
}
#pragma mark - Override

#pragma mark - Public SEL

- (void)track:(NSString *)eventName properties:(nullable NSDictionary<NSString *,id> *)properties{
    NSMutableDictionary*event=[NSMutableDictionary dictionary];
    //设置事件名称
    event[@"distinct_id"] = self.loginId ? : self.deviceId;
    event[@"event"]=eventName;
    //设置事件发生的时间戳，单位为毫秒
    event[@"time"]=[NSNumber numberWithLong:NSDate.date.timeIntervalSince1970*1000];
    
    NSMutableDictionary *eventProperties=[NSMutableDictionary dictionary];//添加预置属性
    [eventProperties addEntriesFromDictionary:self.automaticProperties];
    //添加自定义属性
    [eventProperties addEntriesFromDictionary:properties];
    //设置事件属性
    event[@"properties"]=eventProperties;
    //在Xcode控制台中打印事件日志
    [self _printEvent:event];
    [self.fileStore saveEvent:event];
}

- (void)trackAppClickWithView:(UIView*)view properties:(NSDictionary<NSString*,id>*)properties{
    
    NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
    
    [eventProperties setObject:NSStringFromClass([view class]) forKey:@"elementType"];
    [eventProperties setObject:NSStringFromClass([view.sensorsdata_viewController class]) forKey:@"$screen_name"];
    [eventProperties addEntriesFromDictionary:properties];
    
    [[SensorsAnalyticsSDK sharedInstance] track:@"$AppClick" properties:eventProperties];
}

- (void)trackAppClickWithTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath properties:(nullable NSDictionary<NSString *,id> *)properties{
    NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
    // 添加自定义属性
    [eventProperties addEntriesFromDictionary:properties];
    
    [[SensorsAnalyticsSDK sharedInstance] track:@"$TableViewClick" properties:eventProperties];
}

- (void)saveDeviceId:(NSString *)deviceId {
    // 保存设备ID
    [[NSUserDefaults standardUserDefaults] setObject:deviceId forKey:@"Sensors-DeviceId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)login:(NSString*)loginId{
    self.loginId = loginId;
    
    [[NSUserDefaults standardUserDefaults] setObject:loginId forKey:@"SensorsAnaly-ticsLoginId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Private SEL

- (void)_printEvent:(NSDictionary*)eventDic{
    NSLog(@"%@",eventDic);
}

#pragma mark - Protocol Conform

#pragma mark - Getters

// 获取基础，可自定义扩展
-(NSDictionary<NSString*,id>*)collectAutomaticProperties{
    
    NSMutableDictionary *properties=[NSMutableDictionary dictionary];
    //操作系统类型
    properties[@"$os"]=@"iOS";
    return [properties copy];
}

- (NSString *)deviceId{
    if (!_deviceId) {
        _deviceId = [[NSUserDefaults standardUserDefaults] valueForKey:@"Sensors-DeviceId"];
        if (_deviceId) {
            return _deviceId;
        }
        
        if ([ASIdentifierManager sharedManager].isAdvertisingTrackingEnabled){
            _deviceId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        }
        
        if (!_deviceId) {
            _deviceId =  UIDevice.currentDevice.identifierForVendor.UUIDString;
        }
        
        if (!_deviceId) {
            _deviceId =  NSUUID.UUID.UUIDString;
        }
        
        [self saveDeviceId:_deviceId];
    }
    return _deviceId;
}

@end
