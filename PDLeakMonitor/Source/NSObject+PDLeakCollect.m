//
//  NSObject+PDLeakCollect.m
//  PDLeakMonitor
//
//  Created by liang on 2019/12/23.
//  Copyright © 2019 liang. All rights reserved.
//

#import "NSObject+PDLeakCollect.h"
#import <objc/runtime.h>
#import "PDClassInfo.h"
#import "PDLeakConfiguration.h"
#import "NSObject+PDLeakProxy.h"

@implementation NSObject (PDLeakCollect)

- (void)pd_collectAllRetainedIvarsWithLevel:(NSUInteger)level {
    if (level >= 5) { return; }
    
    PDLeakConfiguration *configuration = [PDLeakConfiguration globalConfiguration];
    if ([configuration classShouldBeIgnore:[self class]]) { return; }
            
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSMutableArray<PDClassIvarInfo *> *ivarInfos = [NSMutableArray array];

        // Find all properties to rootClass.
        Class cls = [self class];
        while (cls && ![configuration classShouldBeIgnore:cls]) {
            PDClassInfo *classInfo = [PDClassInfo classInfoWithClass:cls];
            NSArray *values = classInfo.ivarInfos.allValues;
            [ivarInfos addObjectsFromArray:values];
            
            cls = [cls superclass];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Bind `owner` for `pd_leakProxy` and collect next level ivars.
            for (PDClassIvarInfo *ivarInfo in ivarInfos) {
                BOOL ivarIsObject = ((ivarInfo.type & PDEncodingTypeMask) == PDEncodingTypeObject);
                if (!ivarIsObject) { continue; }
                
                BOOL ivarIsRetained = ((ivarInfo.type & PDEncodingTypePropertyMask) == PDEncodingTypePropertyRetain ||
                                       (ivarInfo.type & PDEncodingTypePropertyMask) == PDEncodingTypePropertyCopy);
                if (!ivarIsRetained) { continue; }

                id value = object_getIvar(self, ivarInfo.ivar);
                if (!value) { continue; }
                
                if ([value markingAlive]) {
                    [value pd_leakProxy].owner = self;
                    [value pd_collectAllRetainedIvarsWithLevel:level + 1];
                }
            }
        });
    });
}

@end
