//
//  ViewController.m
//  ScheduleDemo
//
//  Created by 谢跃聪 on 2020/8/3.
//  Copyright © 2020 yc. All rights reserved.
//

#import "ViewController.h"
#import "ScheduleView.h"

#define WINDOW_WIDTH [[UIScreen mainScreen] bounds].size.width
#define WINDOW_HEIGHT [[UIScreen mainScreen] bounds].size.height

#define WEEKDAY     7
#define DAY_TIME    24

@interface ViewController ()

@property (strong, nonatomic) ScheduleView *scheduleView;

@end

@implementation ViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    [self initUI];
}

- (void)initUI {
    UIButton *clearBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    clearBtn.frame = CGRectMake(10, 10, 100, 30);
    [clearBtn setTitle:@"Clear" forState:UIControlStateNormal];
    [clearBtn addTarget:self action:@selector(clearAllSelect) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:clearBtn];
    
    self.scheduleView = [[ScheduleView alloc] initWithFrame:CGRectMake(0, 50, WINDOW_WIDTH, WINDOW_WIDTH/24*7*1.3)];
    [self.view addSubview:self.scheduleView];
}

#pragma mark - Action
- (void)clearAllSelect {
    [self.scheduleView resetSelect];
}

@end
