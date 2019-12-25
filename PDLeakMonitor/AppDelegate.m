//
//  AppDelegate.m
//  PDLeakMonitor
//
//  Created by liang on 2019/12/20.
//  Copyright © 2019 liang. All rights reserved.
//

#import "AppDelegate.h"
#import "PDLeakConfiguration.h"
#import "PDLeakMonitor.h"

@interface AppDelegate () <PDLeakMonitorDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Launch leak monitor.
    PDLeakMonitor *monitor = [PDLeakMonitor globalMonitor];
    monitor.delegate = self;
    [monitor install];
    
    return YES;
}

- (void)leakMonitor:(PDLeakMonitor *)leakMonitor catchMemoryLeakObject:(id)anObject {
    NSString *message = [NSString stringWithFormat:@"object [%@] maybe leak.", anObject];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"[Warning]" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Get" style:UIAlertActionStyleDestructive handler:nil]];
    
    UIViewController *controller = [self validWindow].rootViewController;
    [controller presentViewController:alertController animated:YES completion:nil];
}

- (UIWindow *)validWindow {
    UIWindow *window = nil;
    
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *windowScene in [UIApplication sharedApplication].connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                window = windowScene.windows.firstObject;
                break;
            }
        }
    } else {
        window = [UIApplication sharedApplication].keyWindow;
    }
    return window;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
