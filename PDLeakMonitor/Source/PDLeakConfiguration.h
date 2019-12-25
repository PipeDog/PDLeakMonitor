//
//  PDLeakConfiguration.h
//  PDLeakMonitor
//
//  Created by liang on 2019/12/23.
//  Copyright © 2019 liang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDLeakConfiguration : NSObject

@property (class, strong, readonly) PDLeakConfiguration *globalConfiguration;

- (void)setPingTimeInterval:(NSTimeInterval (^)(void))block;
- (NSTimeInterval)pingTimeInterval;

- (void)setEffectiveAfterTimes:(NSUInteger (^)(void))block;
- (NSUInteger)effectiveAfterTimes;

 - (void)setIgnoreClassCondition:(BOOL (^)(Class cls))block;
 - (BOOL)classShouldBeIgnore:(Class)cls;

@end

NS_ASSUME_NONNULL_END
