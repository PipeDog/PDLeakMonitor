//
//  PDLeakConfiguration.m
//  PDLeakMonitor
//
//  Created by liang on 2019/12/23.
//  Copyright © 2019 liang. All rights reserved.
//

#import "PDLeakConfiguration.h"

#define Lock() dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER)
#define Unlock() dispatch_semaphore_signal(self->_lock)

@implementation PDLeakConfiguration {
    NSTimeInterval _pingTimeInterval;
    NSUInteger _effectiveAfterTimes;

    BOOL (^_ignoreClassCondition)(Class cls);

    dispatch_semaphore_t _lock;
    // The `_cacheClasses` is used to cache whether a class belongs to the system class.
    NSMutableDictionary<NSString *, NSNumber *> *_cacheClasses;
}

+ (PDLeakConfiguration *)globalConfiguration {
    static PDLeakConfiguration *_globalConfiguration;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _globalConfiguration = [[self alloc] init];
    });
    return _globalConfiguration;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commitInit];
    }
    return self;
}

- (void)commitInit {
    _pingTimeInterval = 2.f;
    _effectiveAfterTimes = 2;
    
    _lock = dispatch_semaphore_create(1);
    _cacheClasses = [NSMutableDictionary dictionary];
}

#pragma mark - Public Methods
- (void)setPingTimeInterval:(NSTimeInterval (^)(void))block {
    if (block) {
        _pingTimeInterval = block();
    }
}

- (NSTimeInterval)pingTimeInterval {
    return _pingTimeInterval;
}

- (void)setEffectiveAfterTimes:(NSUInteger (^)(void))block {
    if (block) {
        _effectiveAfterTimes = block();
    }
}

- (NSUInteger)effectiveAfterTimes {
    return _effectiveAfterTimes;
}

- (void)setIgnoreClassCondition:(BOOL (^)(Class  _Nonnull __unsafe_unretained))block {
    if (block) {
        _ignoreClassCondition = [block copy];
    }
}

- (BOOL)classShouldBeIgnore:(Class)cls {
    if ([self _isSystemClass:cls]) {
        return YES;
    }
    return (_ignoreClassCondition ? _ignoreClassCondition(cls) : NO);
}

#pragma mark - Tool Methods
- (BOOL)_isSystemClass:(Class)cls {
    if (!cls) { return NO; }
        
    NSString *classname = NSStringFromClass(cls);    
    NSNumber *condition = _cacheClasses[classname];
    
    if (condition == nil) {
        /**
            @eg:
            /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/System/Library/PrivateFrameworks/UIKitCore.framework
         */
        NSBundle *bundle = [NSBundle bundleForClass:cls];
        BOOL isSystemClass = [bundle.bundlePath containsString:@"PrivateFrameworks"];
        
        Lock();
        _cacheClasses[classname] = @(isSystemClass);
        Unlock();
        return isSystemClass;
    }

    return [condition boolValue];
}

@end
