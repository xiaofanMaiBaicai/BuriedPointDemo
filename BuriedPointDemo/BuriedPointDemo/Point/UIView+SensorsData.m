//
//  UIView+SensorsData.m
//  BuriedPointDemo
//
//  Created by LYL on 2021/9/13.
//

#import "UIView+SensorsData.h"

@implementation UIView (SensorsData)

- (UIViewController*)sensorsdata_viewController{
    UIResponder *responder = self;
    while ((responder = [responder nextResponder])) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)responder;
        }
    }
    return nil;
}


@end
