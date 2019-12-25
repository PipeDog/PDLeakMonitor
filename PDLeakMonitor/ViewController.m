//
//  ViewController.m
//  PDLeakMonitor
//
//  Created by liang on 2019/12/20.
//  Copyright © 2019 liang. All rights reserved.
//

#import "ViewController.h"
#import "PDLeakViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)didClickButton:(id)sender {
    PDLeakViewController *controller = [[PDLeakViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
