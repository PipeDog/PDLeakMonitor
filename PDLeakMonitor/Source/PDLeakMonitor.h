//
//  PDLeakMonitor.h
//  PDLeakMonitor
//
//  Created by liang on 2019/12/23.
//  Copyright © 2019 liang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PDLeakMonitor;

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const PDLeakMonitorPingNotification;
FOUNDATION_EXPORT NSString *const PDLeakMonitorPongNotification;

@protocol PDLeakMonitorMember <NSObject>

+ (void)prepareForLeakMonitor;

- (BOOL)markingAlive;
- (BOOL)isAlive;

@end

@protocol PDLeakMonitorDelegate <NSObject>

@optional
// Catch memory leak object, upload to server or alert here.
- (void)leakMonitor:(PDLeakMonitor *)leakMonitor catchMemoryLeakObject:(id)anObject;

@end

@interface PDLeakMonitor : NSObject

@property (class, strong, readonly) PDLeakMonitor *globalMonitor;
@property (nonatomic, weak) id<PDLeakMonitorDelegate> delegate;

- (void)addSpecifiedClassList:(NSArray<NSString *> * (^)(void))block;

- (void)install;

@end

NS_ASSUME_NONNULL_END
