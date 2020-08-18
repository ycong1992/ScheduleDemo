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

@interface ScheduleView () <UIGestureRecognizerDelegate>
{
    CGFloat paddingLeft;// 时间表左边栏宽度
    CGFloat paddingTop; // 时间表顶部栏高度
    CGFloat viewWidth;  // 时间表内容总宽度
    CGFloat viewHeight; // 时间表内容总高度
    CGFloat hWidth;     // 时间cell宽度
    CGFloat vHeight;    // 时间cell高度
    CGFloat cycleRadius;// 圆的半径
    
    CGPoint startPoint; // 起点
    CGPoint endPoint;   // 终点
}
@end

@implementation ScheduleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        paddingLeft = 60;
        paddingTop = 40;
        viewWidth = CGRectGetWidth(self.frame)-paddingLeft;
        viewHeight = CGRectGetHeight(self.frame)-paddingTop;
        hWidth = viewWidth / DAY_TIME;
        vHeight = viewHeight / WEEKDAY;
        startPoint = CGPointMake(-1, -1);
        endPoint = CGPointMake(-1, -1);
        cycleRadius = hWidth*0.4;
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
        [self addGestureRecognizer:panGesture];
        panGesture.delegate = self;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    NSLog(@"%s", __func__);
    [[UIColor whiteColor] setFill];
    UIRectFill(rect);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
    CGContextSetLineWidth(context, 1);
    CGContextBeginPath(context);

    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, viewWidth+paddingLeft, 0);
    
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, paddingLeft, paddingTop);

    for (int i = 0; i <= DAY_TIME; i++) {
        CGContextMoveToPoint(context, i*hWidth+paddingLeft, 0);
        CGContextAddLineToPoint(context, i*hWidth+paddingLeft, viewHeight+paddingTop);
    }
    for (int j = 0; j <= WEEKDAY; j++) {
        CGContextMoveToPoint(context, 0, j*vHeight+paddingTop);
        CGContextAddLineToPoint(context, viewWidth+paddingLeft, j*vHeight+paddingTop);
    }
    CGContextStrokePath(context);
    
    UIColor *textColor = [UIColor blackColor];
    UIFont *textFont = [UIFont systemFontOfSize:10];
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle alloc] init];
    textStyle.alignment = NSTextAlignmentCenter;//水平居中
    NSDictionary *attributesDic = @{NSFontAttributeName:textFont,
                                    NSForegroundColorAttributeName:textColor,
                                    NSParagraphStyleAttributeName:textStyle};
    NSString *numText = @"1";
    NSArray *weekArray = @[@"星期日",@"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六"];
    CGSize textSize = [numText sizeWithAttributes:attributesDic];
    for (int k = 0; k < WEEKDAY*DAY_TIME; k++) {
        @autoreleasepool {
            numText = [NSString stringWithFormat:@"%d", k%DAY_TIME+1];
            CGFloat textX = k%DAY_TIME*hWidth+paddingLeft;
            CGFloat textY = k/DAY_TIME*vHeight+(vHeight-textSize.height)/2+paddingTop;
            CAShapeLayer *layer = [[CAShapeLayer alloc] init];
            layer.frame = CGRectMake(textX+(hWidth-cycleRadius*2)/2, k/DAY_TIME*vHeight+paddingTop+(vHeight-cycleRadius*2)/2, cycleRadius*2, cycleRadius*2);
            layer.backgroundColor = [UIColor colorWithRed:0/255.0 green:255/255.0 blue:255/255.0 alpha:0.5].CGColor;
            layer.cornerRadius = cycleRadius;
            [self.layer addSublayer:layer];
            layer.hidden = YES;
            [numText drawInRect:CGRectMake(textX, textY, hWidth, vHeight) withAttributes:attributesDic];
            if (k < DAY_TIME) {
                [numText drawInRect:CGRectMake(k%DAY_TIME*hWidth+paddingLeft, (paddingTop-textSize.height)/2, hWidth, paddingTop) withAttributes:attributesDic];
            }
            if (k%DAY_TIME == 1) {// 1 25 49
                [weekArray[k/DAY_TIME] drawInRect:CGRectMake(0, k/DAY_TIME*vHeight+(vHeight-textSize.height)/2+paddingTop, paddingLeft, vHeight) withAttributes:attributesDic];
            }
        }
    }
    numText = @"周";
    [numText drawInRect:CGRectMake(10, paddingTop/2, paddingLeft/2, paddingTop/2) withAttributes:attributesDic];
    numText = @"小时";
    [numText drawInRect:CGRectMake(paddingLeft/2, 10, paddingLeft/2, paddingTop/2) withAttributes:attributesDic];
}

#pragma mark - <UIGestureRecognizerDelegate>
- (void)panGesture:(UIPanGestureRecognizer *)gestureRecongnizer {
    CGPoint currentPoint = [gestureRecongnizer locationInView:self];
    if (currentPoint.x <= paddingLeft || currentPoint.y <= paddingTop) {
        return;
    }
    if (gestureRecongnizer.state == UIGestureRecognizerStateBegan) {
        startPoint = currentPoint;
        return;
    }
    if (startPoint.x == -1 ) {
        return;
    }
    if (gestureRecongnizer.state == UIGestureRecognizerStateChanged) {

    } else if (gestureRecongnizer.state == UIGestureRecognizerStateEnded) {
        endPoint = currentPoint;
        int minX = ((startPoint.x > endPoint.x ? endPoint.x : startPoint.x) - paddingLeft)/hWidth;
        int minY = ((startPoint.y > endPoint.y ? endPoint.y : startPoint.y) - paddingTop)/vHeight;
        int maxX = ((startPoint.x > endPoint.x ? startPoint.x : endPoint.x) - paddingLeft)/hWidth;
        int maxY = ((startPoint.y > endPoint.y ? startPoint.y : endPoint.y) - paddingTop)/vHeight;
        // Mark-modify
        NSArray *arr = self.layer.sublayers;
        if (arr.count == 7*24) {
            for (int i = minY; i <= maxY; i++) {
                for (int j = minX; j <= maxX; j++) {
                    ((CAShapeLayer*)(arr[i*24+j])).hidden = NO;
                }
            }
        }
        startPoint = CGPointMake(-1, -1);
        endPoint = CGPointMake(-1, -1);
    } else {
        startPoint = CGPointMake(-1, -1);
        endPoint = CGPointMake(-1, -1);
    }
}

#pragma mark - Public Methods
- (void)resetSelect {
    NSArray *arr = self.layer.sublayers;
    if (arr.count == 7*24) {
        for (int i = 0; i < 7*24; i++) {
            ((CAShapeLayer*)(arr[i])).hidden = YES;
        }
    }
}

@end
