//
//  SensorsAnalyticsFileStore.h
//  BuriedPointDemo
//
//  Created by LYL on 2021/9/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SensorsAnalyticsFileStore : NSObject

@property (nonatomic, copy, readonly) NSArray<NSDictionary *> *allEvents;

- (void)saveEvent:(NSDictionary *)event;

// 删除到第几条
- (void)deleteEventsForCount:(NSInteger)count;

@end

NS_ASSUME_NONNULL_END
