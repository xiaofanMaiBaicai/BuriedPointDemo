//
//  NSObject+SASwizzler.m
//  BuriedPointDemo
//
//  Created by LYL on 2021/9/13.
//

#import "NSObject+SASwizzler.h"
#import<objc/runtime.h>
#import<objc/message.h>

@implementation NSObject (SASwizzler)


/// 方法交互
/// @param originalSEL 原方法
/// @param alternateSEL 要交换的方法名称
+(BOOL)sensorsdata_swizzleMethod:(SEL)originalSEL withMethod:(SEL)alternateSEL{
    Method originalMethod = class_getInstanceMethod(self, originalSEL);
    if (!originalMethod) {
        return NO;
    }
    
    Method alternateMethod = class_getInstanceMethod(self, alternateSEL);
    if (!alternateMethod) {
        return NO;
    }
    
    method_exchangeImplementations(originalMethod, alternateMethod);
    
    return YES;
}

@end
