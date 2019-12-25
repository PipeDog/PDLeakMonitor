//
//  PDLeakProxy.m
//  PDLeakMonitor
//
//  Created by liang on 2019/12/23.
//  Copyright © 2019 liang. All rights reserved.
//

#import "PDLeakProxy.h"
#import "PDLeakMonitor.h"
#import "PDLeakConfiguration.h"

static void dispatch_async_safe_main_queue(dispatch_block_t blk) {
    if (0 == strcmp(dispatch_queue_get_label(dispatch_get_main_queue()),
                    dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))) {
        blk();
    } else {
        dispatch_async(dispatch_get_main_queue(), blk);
    }
}

@implementation PDLeakProxy {
    BOOL _hasReported;
    NSUInteger _checkErrorCount;
}

- (void)dealloc {
    [self resignListen];
}

- (instancetype)init {
    id target;
    return [self initWithTarget:target];
}

- (instancetype)initWithTarget:(id)target {
    if (!target) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        _target = target;
        _hasReported = NO;
        _checkErrorCount = 0;
        
        [self resignListen];
        [self listen];
    }
    return self;
}

#pragma mark - Private Methods
- (void)listen {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RCVPing:) name:PDLeakMonitorPingNotification object:nil];
}

- (void)resignListen {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PDLeakMonitorPingNotification object:nil];
}

- (void)RCVPing:(NSNotification *)notification {
    if (_hasReported) {
        [self resignListen];
        return;
    }

    if (!self.target) {
        NSAssert(NO, @"Should be dealloc, find proxy's owner.");
        return;
    }
    
    // Proxy's target should be dead, but target is not released, maybe creates a memory leak.
    if (![self.target isAlive]) {
        _checkErrorCount++;
    }
    
    PDLeakConfiguration *configuration = [PDLeakConfiguration globalConfiguration];
    if (_checkErrorCount >= configuration.effectiveAfterTimes) {
        [self pong];
    }
}

- (void)pong {
    if (_hasReported) {
        [self resignListen];
        return;
    }
    
    _hasReported = YES;
    
    dispatch_async_safe_main_queue(^{
        [[NSNotificationCenter defaultCenter] postNotificationName:PDLeakMonitorPongNotification object:self.target];
    });
}

@end
