//
//  SensorsAnalyticsFileStore.m
//  BuriedPointDemo
//
//  Created by LYL on 2021/9/23.
//

#import "SensorsAnalyticsFileStore.h"

// 默认文件名
static NSString * const SensorsAnalyticsDefaultFileName = @"SensorsAnalyticsData.plist";

@interface SensorsAnalyticsFileStore ()

@property (nonatomic, copy) NSString *filePath;

@property (nonatomic, strong) NSMutableArray<NSDictionary *> *events;

@property (nonatomic, strong) dispatch_queue_t queue;

/// 本地可最大缓存事件条数
@property (nonatomic, assign) NSUInteger maxLocalEventCount;

@end

@implementation SensorsAnalyticsFileStore

#pragma mark - Life Cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        // 初始化默认的事件数据存储地址
        _filePath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:SensorsAnalyticsDefaultFileName];
        _queue = dispatch_queue_create(@"cn.sensorsdata.serialQueue.SensorsAnalyticsFileStore", DISPATCH_QUEUE_SERIAL);
        
        [self _readAllEventsFromFilePath:_filePath];
        
        _maxLocalEventCount = 10000;
    }
    return self;
}

- (void)dealloc {
    
}

#pragma mark - Setters

#pragma mark - Override

#pragma mark - Public SEL

- (void)saveEvent:(NSDictionary *)event{
    dispatch_async(self.queue, ^{
        if (self.events.count >= self.maxLocalEventCount) {
            [self.events removeObjectAtIndex:0];
        }
        // 在数组中直接添加事件数据
        [self.events addObject:event];
        // 将事件数据保存在文件中
        [self _writeEventsToFile];
    });
}

- (void)deleteEventsForCount:(NSInteger)count{
    dispatch_async(self.queue, ^{
        [self.events removeObjectsInRange:NSMakeRange(0, count)];
        [self _writeEventsToFile];
    });
}

#pragma mark - Private SEL

- (void)_readAllEventsFromFilePath:(NSString *)filePath{
    dispatch_async(self.queue, ^{
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        if (data) {
            NSMutableArray *historyEvents = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            self.events = historyEvents ? : [NSMutableArray array];
        } else {
            self.events = [NSMutableArray array];
        }
    });
}

- (void)_writeEventsToFile{
    NSError *error = nil;
    // 将字典数据解析成JSON数据
    NSData *data = [NSJSONSerialization dataWithJSONObject:self.events options: NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"The json object's serialization error: %@", error);
        return ;
    }
    // 将数据写入文件
    [data writeToFile:self.filePath atomically:YES];
}

#pragma mark - Protocol Conform

#pragma mark - Getters

- (NSArray<NSDictionary *> *)allEvents {
    return [self.events copy];
}

@end
