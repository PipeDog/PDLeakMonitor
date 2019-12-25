//
//  NSObject+PDLeakProxy.h
//  PDLeakMonitor
//
//  Created by liang on 2019/12/23.
//  Copyright © 2019 liang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDLeakProxy.h"
#import "PDLeakMonitor.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (PDLeakProxy) <PDLeakMonitorMember>

@property (nonatomic, strong) PDLeakProxy *pd_leakProxy;

@end

NS_ASSUME_NONNULL_END
