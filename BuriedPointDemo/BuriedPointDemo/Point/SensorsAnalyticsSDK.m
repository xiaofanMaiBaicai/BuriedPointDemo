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

#define SensorsDeviceId @"Sensors-DeviceId"
#define SensorsAnalyTicsLoginId @"SensorsAnaly-TicsLoginId"
#define SensorsAnalyticsEventBeginKey @"event_begin"
#define SensorsAnalyticsEventDurationKey @"event_duration"
#define SensorsAnalyticsEventIsPauseKey @"is_pause"

@interface SensorsAnalyticsSDK ()

/// 标记应用程序是否已收到UIApplicationWillResignActiveNotification本地通知 ,用于app启动及退出
@property (nonatomic, assign) BOOL applicationWillResignActive;

/// 是否为被动启动
@property (nonatomic,assign) BOOL launchedPassively;



// 默认属性
@property (nonatomic, strong) NSDictionary <NSString *, id> *automaticProperties;

@property (nonatomic, copy) NSString *loginId;

@property (nonatomic, strong) SensorsAnalyticsFileStore *fileStore;

/// 事件开始发生的时间戳
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSDictionary *> *trackTimer;

///保存进入后台时未暂停的事件名称
@property(nonatomic, strong) NSMutableArray<NSString*> *enterBackgroundTrackTimerEvents;

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
        _launchedPassively = UIApplication.sharedApplication.backgroundTimeRemaining != UIApplicationBackgroundFetchIntervalNever;
        _loginId = [[NSUserDefaults standardUserDefaults] objectForKey:SensorsAnalyTicsLoginId];
        _fileStore = [[SensorsAnalyticsFileStore alloc]init];
        _trackTimer = [NSMutableDictionary dictionary];
        _enterBackgroundTrackTimerEvents = [NSMutableArray array];
        [self setupListeners];
        [SensorsAnalyticsExceptionHandler sharedInstance];
    }
    return self;
}

#pragma mark - Life Cycle

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

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


#pragma mark - Private SEL

- (void)_printEvent:(NSDictionary*)eventDic{
    NSLog(@"%@",eventDic);
}

- (double)_currentTime {
    return [[NSDate date] timeIntervalSince1970] * 1000;
}

- (double)_systemUpTime {
    return NSProcessInfo.processInfo.systemUptime * 1000;
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

#pragma mark - tableView的cell点击事件

- (void)trackAppClickWithTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath properties:(nullable NSDictionary<NSString *,id> *)properties{
    
    // TODO: 获取用户点击的UITableViewCell控件对象
    // TODO: 设置被用户点击的UITableViewCell控件上的内容（$element_content）
    // TODO: 设置被用户点击的UITableViewCell控件所在的位置（$element_position）
    
    NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
    // 添加自定义属性
    [eventProperties addEntriesFromDictionary:properties];
    [[SensorsAnalyticsSDK sharedInstance] track:@"$TableViewClick" properties:eventProperties];
}


#pragma mark - 控件点击事件

- (void)trackAppClickWithView:(UIView*)view properties:(NSDictionary<NSString*,id>*)properties{
    
    NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
    
    [eventProperties setObject:view.sensorsdata_elementType forKey:@"elementType"];
    [eventProperties setObject:NSStringFromClass([view.sensorsdata_viewController class]) forKey:@"$screen_name"];
    [eventProperties addEntriesFromDictionary:properties];
    
    [[SensorsAnalyticsSDK sharedInstance] track:@"$AppClick" properties:eventProperties];
}


#pragma mark - App启动与退出

- (void)setupListeners {
    // 即当应用程序进入后台后，调用通知方法
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    // 回到前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    
    // 被动启动
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    // 触发$AppEnd事件
    self.applicationWillResignActive = NO;
    [self track:@"$AppEnd" properties:nil];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    // 触发$AppStart事件
    if (self.applicationWillResignActive){
        self.applicationWillResignActive = NO;
        return;
    }
    
    // 将被动启动标记设为NO，正常记录事件
    self.launchedPassively = NO;
    [self track:@"$AppStart" properties:nil];
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    //标记已接收到UIApplicationWillResignActiveNotification本地通知
    //打开即可完成优化
//    self.applicationWillResignActive = YES;
    NSLog(@"UIApplicationWillResignActiveNotification");
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    // 触发被动启动事件
    
    [self track:@"$AppStartPassively" properties:nil];
    
    // 打开即可
//    if (self.launchedPassively) {
//        [self track:@"$AppStartPassively" properties:nil];
//    }
}

#pragma mark - 事件持续时间

// 开始计时
- (void)trackTimerStart:(NSString *)eventName{
    self.trackTimer[eventName] = @{ SensorsAnalyticsEventBeginKey : @([self _currentTime])};
//    self.trackTimer[eventName] = @{SensorsAnalyticsEventBeginKey : @([self _systemUpTime])};
}

// 停止计时
- (void)trackTimerEnd:(NSString *)eventName properties:(nullable NSDictionary<NSString *,id> *)properties{
    NSDictionary *eventTimer = self.trackTimer[eventName];
    if (!eventTimer) {
        return [self track:eventName properties:properties];
    }
    
    NSMutableDictionary *p = [NSMutableDictionary dictionaryWithDictionary:properties];
    // 移除
    [self.trackTimer removeObjectForKey:eventName];
    
    // 暂停与恢复时的结束
    if ([eventTimer[SensorsAnalyticsEventIsPauseKey] boolValue]){
        double eventDuration = [eventTimer[SensorsAnalyticsEventDurationKey] doubleValue];
        [p setObject:@([[NSString stringWithFormat:@"%.3lf", eventDuration] floatValue]) forKey:@"event_duration"];
    } else {

        // 事件开始时间
        double beginTime = [(NSNumber *)eventTimer[SensorsAnalyticsEventBeginKey] doubleValue];
        // 获取当前时间-> 获取当前系统启动时间
        double currentTime = [self _systemUpTime];
        // 计算事件时长
        double eventDuration = currentTime - beginTime + [eventTimer[SensorsAnalyticsEventDurationKey] doubleValue];
        // 设置事件时长属性

        [p setObject:@([[NSString stringWithFormat:@"%.3lf", eventDuration] floatValue]) forKey:@"event_duration"];
    }
    
//    // 事件开始时间
//    double beginTime = [(NSNumber *)eventTimer[SensorsAnalyticsEventBeginKey] doubleValue];
//    // 获取当前时间-> 获取当前系统启动时间
//    double currentTime = [self _currentTime];
////    double currentTime = [self _systemUpTime]; //准确
//    // 计算事件时长
//    double eventDuration = currentTime - beginTime;
//    // 设置事件时长属性
//    [p setObject:@([[NSString stringWithFormat:@"%.3lf", eventDuration] floatValue]) forKey:@"event_duration"];
    // 触发事件
    [self track:eventName properties:p];
}

// 暂停统计事件时长
- (void)trackTimerPause:(NSString *)event{
    NSMutableDictionary *eventTimer = [self.trackTimer[event] mutableCopy];
    if (!eventTimer) {
        return;
    }
    
    if ([eventTimer[SensorsAnalyticsEventIsPauseKey] boolValue]) {
        return;
    }
    
    double systemUpTime = [self _systemUpTime];
    // 获取开始时间
    double beginTime = [eventTimer[SensorsAnalyticsEventBeginKey] doubleValue];
    
    // 计算暂停前统计的时长
    double duration = [eventTimer[SensorsAnalyticsEventDurationKey] doubleValue] + systemUpTime - beginTime;
    
    eventTimer[SensorsAnalyticsEventDurationKey] = @(duration);
    // 事件处于暂停状态
    eventTimer[SensorsAnalyticsEventIsPauseKey] = @(YES);
    
    self.trackTimer[event] = eventTimer;
    
}

// 恢复统计事件时长
- (void)trackTimerResume:(NSString*)event{
    NSMutableDictionary *eventTimer = [self.trackTimer[event] mutableCopy];
    if (!eventTimer){
        return;
    }
    // 如果该事件时长统计没有暂停，直接返回，不做任何处理
    if (![eventTimer[SensorsAnalyticsEventIsPauseKey] boolValue]){
        return;
    }
    // 获取当前系统启动时间
    double systemUpTime = [self _systemUpTime];
    // 重置事件开始时间
    eventTimer[SensorsAnalyticsEventBeginKey] = @(systemUpTime);
    // 将事件暂停标记设置为NO
    eventTimer[SensorsAnalyticsEventIsPauseKey] = @(NO);
    self.trackTimer[event] = eventTimer;
}

//// 进入后台
//- (void)applicationDidEnterBackground:(NSNotification*)notification{
//    [self trackTimerEnd:@"$AppEnd" properties:nil];
//    [self.trackTimer enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSDictionary * _Nonnull obj, BOOL * _Nonnull stop) {
//        if (![obj[SensorsAnalyticsEventIsPauseKey] boolValue]){
//            [self.enterBackgroundTrackTimerEvents addObject:key];
//            [self trackTimerPause:key];
//        }
//    }];
//}
//
//// 进入前台
//-(void)applicationDidBecomeActive:(NSNotification*)notification{
//    [self track:@"$AppStart" properties:nil];
//    for (NSString *event in self.enterBackgroundTrackTimerEvents) {
//        [self trackTimerResume:event];
//    }
//    [self.enterBackgroundTrackTimerEvents removeAllObjects];
//    [self trackTimerStart:@"$AppEnd"];
//}

#pragma mark - 用户标识

// 未登录前用户标识
- (NSString *)deviceId{
    if (!_deviceId) {
        _deviceId = [[NSUserDefaults standardUserDefaults] valueForKey:SensorsDeviceId];
        if (_deviceId) {
            return _deviceId;
        }
        // idfa
        if ([ASIdentifierManager sharedManager].isAdvertisingTrackingEnabled){
            _deviceId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        }
        // idfv
        if (!_deviceId) {
            _deviceId =  UIDevice.currentDevice.identifierForVendor.UUIDString;
        }
        // uuid
        if (!_deviceId) {
            _deviceId =  NSUUID.UUID.UUIDString;
        }
        [self saveDeviceId:_deviceId];
    }
    return _deviceId;
}

// 保存设备ID
- (void)saveDeviceId:(NSString *)deviceId {
    [[NSUserDefaults standardUserDefaults] setObject:deviceId forKey:SensorsDeviceId];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 登录后的用户标识并保存
- (void)login:(NSString*)loginId{
    _loginId = loginId;
    
    [[NSUserDefaults standardUserDefaults] setObject:loginId forKey:SensorsAnalyTicsLoginId];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
