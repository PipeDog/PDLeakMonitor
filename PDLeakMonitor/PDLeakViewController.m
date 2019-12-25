//
//  PDLeakViewController.m
//  PDLeakMonitor
//
//  Created by liang on 2019/12/25.
//  Copyright © 2019 liang. All rights reserved.
//

#import "PDLeakViewController.h"

@interface PDLeakViewController ()

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation PDLeakViewController

- (void)dealloc {
    NSLog(@"dealloc %@", [self class]);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.timer = [NSTimer timerWithTimeInterval:1.f target:self selector:@selector(tick:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    [self.timer fire];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSStringFromClass([self class]);
}

- (void)tick:(NSTimer *)timer {
    NSLog(@"%@", [NSDate date]);
}

@end
