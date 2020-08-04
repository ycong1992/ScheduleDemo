//
//  ScheduleView.m
//  ScheduleDemo
//
//  Created by 谢跃聪 on 2020/8/3.
//  Copyright © 2020 yc. All rights reserved.
//

#import "ScheduleView.h"

#define WEEKDAY     7
#define DAY_TIME    24

@implementation ScheduleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    self.backgroundColor = [UIColor whiteColor];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
    CGContextSetLineWidth(context, 1);
    CGContextBeginPath(context);
    
    CGFloat viewWidth = CGRectGetWidth(self.frame);
    CGFloat viewHeight = CGRectGetHeight(self.frame);
    
    CGFloat hWidth = viewWidth / DAY_TIME;
    CGFloat vHeight = viewHeight / WEEKDAY;

    for (int i = 0; i <= DAY_TIME; i++) {
        CGContextMoveToPoint(context, i*hWidth, 0);
        CGContextAddLineToPoint(context, i*hWidth, viewHeight);
    }
    for (int j = 0; j <= WEEKDAY; j++) {
        CGContextMoveToPoint(context, 0, j*vHeight);
        CGContextAddLineToPoint(context, viewWidth, j*vHeight);
    }
    CGContextStrokePath(context);
    
    UIColor *textColor = [UIColor blackColor];
    UIFont *textFont = [UIFont systemFontOfSize:10];
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle alloc] init];
    textStyle.alignment = NSTextAlignmentCenter;//水平居中
    NSString *numText;
    
    for (int k = 0; k < WEEKDAY*DAY_TIME; k++) {
        numText = [NSString stringWithFormat:@"%d", k%DAY_TIME+1];
        CGFloat textX = k%DAY_TIME*hWidth;
        CGFloat textY = k/DAY_TIME*vHeight;
        [numText drawInRect:CGRectMake(textX, textY, hWidth, vHeight)
             withAttributes:@{NSFontAttributeName:textFont,
                              NSForegroundColorAttributeName:textColor,
                              NSParagraphStyleAttributeName:textStyle}];
    }

}

@end
