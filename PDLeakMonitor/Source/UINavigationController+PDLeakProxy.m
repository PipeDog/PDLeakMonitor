//
//  UINavigationController+PDLeakProxy.m
//  PDLeakMonitor
//
//  Created by liang on 2019/12/23.
//  Copyright © 2019 liang. All rights reserved.
//

#import "UINavigationController+PDLeakProxy.h"
#import "NSObject+PDLeakProxy.h"
#import "PDHooker.h"

@implementation UINavigationController (PDLeakProxy)

- (void)_pd_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self _pd_pushViewController:viewController animated:animated];
    [viewController markingAlive];
}

#pragma mark - PDLeakMonitorMember Methods
+ (void)prepareForLeakMonitor {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        class_exchangeInstanceMethod([self class],
                                     @selector(pushViewController:animated:),
                                     @selector(_pd_pushViewController:animated:));
    });
}

@end
