//
//  UIView+PDLeakProxy.m
//  PDLeakMonitor
//
//  Created by liang on 2019/12/23.
//  Copyright © 2019 liang. All rights reserved.
//

#import "UIView+PDLeakProxy.h"
#import <objc/runtime.h>
#import "PDHooker.h"
#import "NSObject+PDLeakProxy.h"

@implementation UIView (PDLeakProxy)

- (void)_pd_didMoveToWindow {
    [self _pd_didMoveToWindow];
    [self markingAliveSelf];
}

- (void)_pd_didMoveToSuperview {
    [self _pd_didMoveToSuperview];
    [self markingAliveSelf];
}

#pragma mark - PDLeakMonitorMember Methods
+ (void)prepareForLeakMonitor {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        class_exchangeInstanceMethod([self class],
                                     @selector(didMoveToWindow),
                                     @selector(_pd_didMoveToWindow));
        class_exchangeInstanceMethod([self class],
                                     @selector(didMoveToSuperview),
                                     @selector(_pd_didMoveToSuperview));
    });
}

- (BOOL)isAlive {
    BOOL inResponderChain = [self inResponderChain];

    // Bind responder.
    if (!self.pd_leakProxy.responder) {
        self.pd_leakProxy.responder = [self finalResponder];
    }

    if (inResponderChain) { return YES; }
    if ([self.pd_leakProxy.responder isKindOfClass:[UIViewController class]]) { return YES; }
    return NO;
}

#pragma mark - Tool Methods
- (BOOL)inResponderChain {
    UIView *view = self;
    while (view.superview) {
        view = view.superview;
    }
    return [view isKindOfClass:[UIWindow class]];
}

- (UIResponder *)finalResponder { // Rename method name.
    UIResponder *resp = self.nextResponder;
    while (resp.nextResponder) {
        resp = resp.nextResponder;
        if ([resp isKindOfClass:[UIViewController class]]) {
            break;
        }
    }
    return resp;
}

- (void)markingAliveSelf {
    BOOL hasAliveParent = NO;
    UIResponder *resp = self.nextResponder;
    
    while (resp) {
        if (resp.pd_leakProxy) {
            hasAliveParent = YES;
            break;
        }
        resp = resp.nextResponder;
    }
    
    if (hasAliveParent) {
        [self markingAlive];
    }
}

@end
