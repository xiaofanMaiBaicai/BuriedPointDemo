//
//  NSObject+SASwizzler.h
//  BuriedPointDemo
//
//  Created by LYL on 2021/9/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (SASwizzler)

/// 方法交互
/// @param originalSEL 原方法
/// @param alternateSEL 要交换的方法名称
+(BOOL)sensorsdata_swizzleMethod:(SEL)originalSEL withMethod:(SEL)alternateSEL;

@end

NS_ASSUME_NONNULL_END
