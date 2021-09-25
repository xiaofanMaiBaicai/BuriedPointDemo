//
//  SensorsAnalyticsExceptionHandler.m
//  BuriedPointDemo
//
//  Created by LYL on 2021/9/23.
//

#import "SensorsAnalyticsExceptionHandler.h"
#import "SensorsAnalyticsSDK.h"

static NSString * const SensorDataSignalExceptionHandlerName = @"SignalExceptionHandler";
static NSString * const SensorDataSignalExceptionHandlerUserInfo = @"SignalExcep-tionHandlerUserInfo";

@interface SensorsAnalyticsExceptionHandler ()

@property (nonatomic) NSUncaughtExceptionHandler *previousExceptionHandler;

@end

@implementation SensorsAnalyticsExceptionHandler

#pragma mark - Life Cycle

+ (instancetype)sharedInstance {
    static SensorsAnalyticsExceptionHandler *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SensorsAnalyticsExceptionHandler alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _previousExceptionHandler =  NSGetUncaughtExceptionHandler();
        NSSetUncaughtExceptionHandler(&sensorsdata_uncaught_exception_handler);
        
        // 定义信号集结构体
        struct sigaction sig;
        // 将信号集初始化为空
        sigemptyset(&sig.sa_mask);
        // 在处理函数中传入__siginfo参数
        sig.sa_flags = SA_SIGINFO;
        // 设置信号集处理函数
        sig.sa_sigaction = &sensorsdata_signal_exception_handler;
        // 定义需要采集的信号类型
        int signals[] = {SIGILL, SIGABRT, SIGBUS, SIGFPE, SIGSEGV};
        for (int i = 0; i < sizeof(signals) / sizeof(int); i++) {
            // 注册信号处理
            int err = sigaction(signals[i], &sig, NULL); if (err) { NSLog(@"Errored while trying to set up sigaction for signal %d", signals[i]);
            }
        }
    }
    return self;
}

- (void)dealloc {
    
}

#pragma mark - Setters

#pragma mark - Override

#pragma mark - Public SEL

static void sensorsdata_uncaught_exception_handler(NSException *exception) {
    // 采集$AppCrashed事件
    [[SensorsAnalyticsExceptionHandler sharedInstance] trackAppCrashedWithException:exception];
    
    NSUncaughtExceptionHandler *handle = [SensorsAnalyticsExceptionHandler sharedInstance].previousExceptionHandler;
    
    if (handle) {
        handle(exception);
    }
}

static void sensorsdata_signal_exception_handler(int sig, struct __siginfo *info, void *context) {
    
    NSDictionary *userInfo = @{SensorDataSignalExceptionHandlerUserInfo: @(sig)};
    NSString *reason = [NSString stringWithFormat:@"Signal %d was raised.", sig];
    NSException *exception = [NSException exceptionWithName:SensorDataSignalExceptionHandlerName reason:reason userInfo:userInfo];
    SensorsAnalyticsExceptionHandler *handler = [SensorsAnalyticsExceptionHandler sharedInstance];
    [handler trackAppCrashedWithException:exception];
}



#pragma mark - Private SEL

- (void)trackAppCrashedWithException:(NSException *)exception { NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    // 异常名称
    NSString *name = [exception name];
    // 出现异常的原因
    NSString *reason = [exception reason];
    // 异常的堆栈信息
    NSArray *stacks = [exception callStackSymbols];
    // 将异常信息组装
    NSString *exceptionInfo = [NSString stringWithFormat:@"Exception name：%@\nException reason：%@\nException stacks：%@",name,reason,stacks];
    // 设置$AppCrashed的事件属性$app_crashed_reason
    properties[@"$app_crashed_reason"] = exceptionInfo;
    
    
    [[SensorsAnalyticsSDK sharedInstance] track:@"$AppCrashed" properties:properties];
    
    NSSetUncaughtExceptionHandler(NULL);
    
    int signals[] = {SIGILL, SIGABRT, SIGBUS, SIGFPE, SIGSEGV};
    for (int i = 0; i < sizeof(signals) / sizeof(int); i++) {
        signal(signals[i], SIG_DFL);
    }
}

#pragma mark - Protocol Conform

#pragma mark - Getters

@end
