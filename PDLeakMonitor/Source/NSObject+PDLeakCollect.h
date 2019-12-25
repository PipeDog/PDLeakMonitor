//
//  NSObject+PDLeakCollect.h
//  PDLeakMonitor
//
//  Created by liang on 2019/12/23.
//  Copyright © 2019 liang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (PDLeakCollect)

- (void)pd_collectAllRetainedIvarsWithLevel:(NSUInteger)level;

@end

NS_ASSUME_NONNULL_END
