//
//  PDLeakProxy.h
//  PDLeakMonitor
//
//  Created by liang on 2019/12/23.
//  Copyright © 2019 liang. All rights reserved.
//
//  `PDLeakProxy` hold by attr `target`.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDLeakProxy : NSObject

@property (nonatomic, weak, nullable, readonly) id target;
@property (nonatomic, weak, nullable) id owner;
@property (nonatomic, weak, nullable) __kindof UIResponder *responder; ///< Nullable, used  by kind of `UIResponder`.

- (instancetype)initWithTarget:(id)target NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
