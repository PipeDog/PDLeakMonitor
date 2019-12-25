//
//  PDHooker.m
//  PDLeakMonitor
//
//  Created by liang on 2019/12/23.
//  Copyright © 2019 liang. All rights reserved.
//

#import "PDHooker.h"
#import <objc/runtime.h>

void class_exchangeInstanceMethod(Class cls, SEL originalSEL, SEL replaceSEL) {
    Method originMethod = class_getInstanceMethod(cls, originalSEL);
    Method replaceMethod = class_getInstanceMethod(cls, replaceSEL);
    
    BOOL success = class_addMethod(cls,
                                   originalSEL,
                                   method_getImplementation(replaceMethod),
                                   method_getTypeEncoding(replaceMethod));
    if (success) {
        class_replaceMethod(cls,
                            replaceSEL,
                            method_getImplementation(originMethod),
                            method_getTypeEncoding(originMethod));
    } else {
        method_exchangeImplementations(originMethod, replaceMethod);
    }
}

void class_exchangeClassMethod(Class cls, SEL originalSEL, SEL replaceSEL) {
    Class metaClass = object_getClass(cls);
    class_exchangeInstanceMethod(metaClass, originalSEL, replaceSEL);
}
