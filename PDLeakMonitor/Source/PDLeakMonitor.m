//
//  PDLeakMonitor.m
//  PDLeakMonitor
//
//  Created by liang on 2019/12/23.
//  Copyright © 2019 liang. All rights reserved.
//

#import "PDLeakMonitor.h"
#import "PDLeakConfiguration.h"

NSString *const PDLeakMonitorPingNotification = @"PDLeakMonitorPingNotification";
NSString *const PDLeakMonitorPongNotification = @"PDLeakMonitorPongNotification";

@implementation PDLeakMonitor {
    NSArray<NSString *> *_specifiedClassList;
    NSTimer *_timer;
    
    struct {
        unsigned catchMemoryLeakObject : 1;
    } _delegateHas;
}

+ (PDLeakMonitor *)globalMonitor {
    static PDLeakMonitor *_globalMonitor;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _globalMonitor = [[self alloc] init];
    });
    return _globalMonitor;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _specifiedClassList = @[
            @"UIView",
            @"UIViewController",
            @"UINavigationController"
        ];
        
        [self listen];
    }
    return self;
}

- (void)addSpecifiedClassList:(NSArray<NSString *> * _Nonnull (^)(void))block {
    if (!block) { return; }

    NSMutableSet *filter = [NSMutableSet set];
    [filter addObjectsFromArray:_specifiedClassList];
    
    NSMutableArray *fullList = [NSMutableArray array];
    [fullList addObjectsFromArray:_specifiedClassList];
    
    NSArray *classList = block();
    for (NSString *element in classList) {
        if (![filter containsObject:element]) {
            [filter addObject:element];
            [fullList addObject:element];
        } else {
            NSAssert(NO, @"Duplicate specified class for class name 「%@」!", element);
        }
    }
    
    _specifiedClassList = [fullList copy];
}

- (void)install {
    for (NSString *element in _specifiedClassList) {
        Class cls = NSClassFromString(element);
        [cls prepareForLeakMonitor];
    }
    
    [self ping];
}

#pragma mark - Ping Methods
- (void)ping {
    NSAssert([NSThread mainThread], @"Must be executed in main thread!");
    if (_timer) { return; }
    
    PDLeakConfiguration *configuration = [PDLeakConfiguration globalConfiguration];
    _timer = [NSTimer timerWithTimeInterval:configuration.pingTimeInterval target:self selector:@selector(tick:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)tick:(NSTimer *)timer {
    [[NSNotificationCenter defaultCenter] postNotificationName:PDLeakMonitorPingNotification object:nil];
}

#pragma mark - Pong Methods
- (void)listen {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RCVPong:) name:PDLeakMonitorPongNotification object:nil];
}

- (void)RCVPong:(NSNotification *)notification {
    id object = notification.object;
    if (!object) { return; }

    if (_delegateHas.catchMemoryLeakObject) {
        [self.delegate leakMonitor:self catchMemoryLeakObject:object];
    }
}

#pragma mark - Setter Methods
- (void)setDelegate:(id<PDLeakMonitorDelegate>)delegate {
    _delegate = delegate;
    
    _delegateHas.catchMemoryLeakObject = [_delegate respondsToSelector:@selector(leakMonitor:catchMemoryLeakObject:)];
}

@end
