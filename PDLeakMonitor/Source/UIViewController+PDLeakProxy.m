//
//  UIViewController+PDLeakProxy.m
//  PDLeakMonitor
//
//  Created by liang on 2019/12/23.
//  Copyright © 2019 liang. All rights reserved.
//

#import "UIViewController+PDLeakProxy.h"
#import <objc/runtime.h>
#import "PDHooker.h"
#import "NSObject+PDLeakProxy.h"
#import "NSObject+PDLeakCollect.h"

@implementation UIViewController (PDLeakProxy)

- (void)_pd_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    [self _pd_presentViewController:viewControllerToPresent animated:flag completion:completion];
    [viewControllerToPresent markingAlive];
}

- (void)_pd_viewDidAppear:(BOOL)animated {
    [self _pd_viewDidAppear:animated];
    [self pd_collectAllRetainedIvarsWithLevel:0];
}

#pragma mark - PDLeakMonitorMember
+ (void)prepareForLeakMonitor {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        class_exchangeInstanceMethod([self class],
                                     @selector(viewDidAppear:),
                                     @selector(_pd_viewDidAppear:));
        class_exchangeInstanceMethod([self class],
                                     @selector(presentViewController:animated:completion:),
                                     @selector(_pd_presentViewController:animated:completion:));
    });
}

- (BOOL)isAlive {
    BOOL visible = [self isVisible];
    BOOL hasContainer = (self.navigationController || self.presentingViewController);
    return (visible || hasContainer);
}

#pragma mark - Tool Methods
- (BOOL)isVisible {
    UIView *view = self.view;
    while (view.superview) {
        view = view.superview;
    }
    return [view isKindOfClass:[UIWindow class]];
}

@end
