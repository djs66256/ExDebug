//
//  ViewController.m
//  MoreDebug
//
//  Created by hzduanjiashun on 2017/2/24.
//  Copyright © 2017年 Daniel. All rights reserved.
//

#import "ViewController.h"
#import <DDMoreDebug/DDDebugSocketManager.h>
#import <DDMoreDebug/DDLogURLProtocol.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    [NSURLProtocol registerClass:DDLogURLProtocol.class];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[DDDebugSocketManager sharedInstance] connect];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:@"https://www.baidu.com"]
         completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
        }] resume];
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
