//
//  UIViewController+PDLeakProxy.h
//  PDLeakMonitor
//
//  Created by liang on 2019/12/23.
//  Copyright © 2019 liang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDLeakMonitor.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (PDLeakProxy) <PDLeakMonitorMember>

@end

NS_ASSUME_NONNULL_END
