//
//  NSObject+PDLeakProxy.m
//  PDLeakMonitor
//
//  Created by liang on 2019/12/23.
//  Copyright © 2019 liang. All rights reserved.
//

#import "NSObject+PDLeakProxy.h"
#import <objc/runtime.h>
#import "PDLeakConfiguration.h"

@implementation NSObject (PDLeakProxy)

#pragma mark - PDLeakMonitorMember Methods
+ (void)prepareForLeakMonitor {
    // Do nothing...
}

- (BOOL)isAlive {
    if (!self.pd_leakProxy) { return NO; }
    // self.target == self
    // if (!self.pd_leakProxy.target) { return NO; }
    if (!self.pd_leakProxy.owner) { return NO; }
    return YES;
}

- (BOOL)markingAlive {
    if (self.pd_leakProxy) {
        return NO;
    }
    
    // Skip class should be ignore.
    PDLeakConfiguration *configuration = [PDLeakConfiguration globalConfiguration];
    if ([configuration classShouldBeIgnore:[self class]]) {
        return NO;
    }

    // The view needs to be held by the container.
    if ([self isKindOfClass:[UIView class]] && ![self hasSuperviewContainer]) {
        return NO;
    }
    
    // The controller needs to be held by the container.
    if ([self isKindOfClass:[UIViewController class]] && ![self hasControllerContainer]) {
        return NO;
    }

    // Bind leak proxy.
    PDLeakProxy *proxy = [[PDLeakProxy alloc] initWithTarget:self];
    self.pd_leakProxy = proxy;
    return YES;
}

#pragma mark - Tool Methods
- (BOOL)hasSuperviewContainer {
    UIView *view = (UIView *)self;
    if (view.superview) {
        return YES;
    }
    return NO;
}

- (BOOL)hasControllerContainer {
    UIViewController *controller = (UIViewController *)self;
    if (controller.navigationController || controller.presentingViewController) {
        return YES;
    }
    return NO;
}

#pragma mark - Setter Methods
- (void)setPd_leakProxy:(PDLeakProxy *)pd_leakProxy {
    objc_setAssociatedObject(self, @selector(pd_leakProxy), pd_leakProxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Getter Methods
- (PDLeakProxy *)pd_leakProxy {
    return objc_getAssociatedObject(self, _cmd);
}

@end
