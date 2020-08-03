//
//  ViewController.m
//  ScheduleDemo
//
//  Created by 谢跃聪 on 2020/8/3.
//  Copyright © 2020 yc. All rights reserved.
//

#import "ViewController.h"

#define WINDOW_WIDTH [[UIScreen mainScreen] bounds].size.width
#define WINDOW_HEIGHT [[UIScreen mainScreen] bounds].size.height

#define WEEKDAY     7
#define DAY_TIME    24

@interface ViewController () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIView *contentView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initUI];
}

- (void)initUI {
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, WINDOW_WIDTH, WINDOW_WIDTH)];
    [self.view addSubview:self.contentView];
    
    CGFloat hWidth =WINDOW_WIDTH/DAY_TIME;
    CGFloat vHeight = hWidth*0.8;
    CGFloat vCount = 0;
    for (int i = 0; i <= DAY_TIME; i++) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(i*hWidth, 0, 1, vHeight*7)];
        view.backgroundColor = [UIColor grayColor];
        [self.contentView addSubview:view];
        if (i != DAY_TIME) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i*hWidth, 0, hWidth, vHeight)];
            label.text = [NSString stringWithFormat:@"%d", i+1];
            label.font = [UIFont systemFontOfSize:10];
            label.textColor = [UIColor blackColor];
            label.textAlignment = NSTextAlignmentCenter;
            [self.contentView addSubview:label];
        }
    }
    
    for (int j = 0; j <= WEEKDAY; j++) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, j*vHeight, WINDOW_WIDTH, 1)];
        view.backgroundColor = [UIColor grayColor];
        [self.contentView addSubview:view];
    }
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    [self.contentView addGestureRecognizer:panGesture];
    panGesture.delegate = self;
}

//- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//
//    UITouch *touch = [touches anyObject];
//    CGPoint point = [touch locationInView:self.view];
//
//    NSLog(@"kkk %f , %f",point.x,point.y);
//}

#pragma mark - <UIGestureRecognizerDelegate>
- (void)panGesture:(UIPanGestureRecognizer *)gestureRecongnizer
{
    CGPoint currentPoint = [gestureRecongnizer locationInView:self.contentView];
    NSLog(@"%@", NSStringFromCGPoint(currentPoint));
    
    _schedulePromptView.hidden = NO;
    
    if (gestureRecongnizer.state == UIGestureRecognizerStateBegan)
    {
        _startPoint = currentPoint;
    }
    else if (gestureRecongnizer.state == UIGestureRecognizerStateChanged)
    {
        CGRect constantRect = CGRectMake(_startPoint.x, _startPoint.y, currentPoint.x - _startPoint.x, currentPoint.y - _startPoint.y);
        
        for (int i = 0 ; i < self.scheduleArray.count; i ++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            UIColor *defaultColor = [self getDefaultColor:indexPath.row];

            MNScheduleViewCell *cell = (MNScheduleViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            
            if (CGRectIntersectsRect(cell.frame, constantRect))
            {
                cell.numberLabel.backgroundColor = CELL_SELECT_COLOR;
                cell.numberLabel.textColor = [UIColor whiteColor];
            }
            else
            {
                cell.numberLabel.backgroundColor = ((schedule_obj *)[_scheduleArray objectAtIndex:indexPath.row]).backgroundColor;
                cell.numberLabel.textColor = ([cell.numberLabel.backgroundColor isEqual: defaultColor]) ? [UIColor lightGrayColor] : [UIColor whiteColor];
            }
        }
        
        CGFloat startY = (_startPoint.y/(CGRectGetHeight(self.collectionView.frame)))*WEEK_DAY_COUNT;
        CGFloat currentY = (currentPoint.y/(CGRectGetHeight(self.collectionView.frame)))*WEEK_DAY_COUNT;
        int i = startY < currentY ? (int)startY : (int)currentY;
        int count = startY < currentY ? (int)currentY : (int)startY;
        
        CGFloat startX = (_startPoint.x/(CGRectGetWidth(self.collectionView.frame)))*ONE_DAY_NUMBER;
        CGFloat currentX = (currentPoint.x/(CGRectGetWidth(self.collectionView.frame)))*ONE_DAY_NUMBER;
        int j = startX < currentX ? (int)startX : (int)currentX;
        int count_X = startX < currentX ? (int)currentX : (int)startX;
        
        if (i >=0 && (count < WEEK_DAY_COUNT)) {

            if (i != _startPointY || count != _currentPointY) {
                _startPointY = i;
                _currentPointY = count;
                NSString *weekString = [NSString string];
                for (; i <= count; i++) {
                    if (weekString.length) {
                        weekString = [weekString stringByAppendingString:@" "];
                    }
                    weekString = [weekString stringByAppendingString:_weekArray[i]];
                }
                
                [_schedulePromptView setScheduleWeek:weekString Time:nil];
                
                CGFloat pointY = (count+1)*(CGRectGetHeight(self.collectionView.frame))/WEEK_DAY_COUNT;
                if (pointY < 0) {
                    pointY = 0;
                } else if (pointY > CGRectGetHeight(self.collectionView.frame) - SCHEDULE_PROMPT_HEIGHT) {
                    pointY = CGRectGetHeight(self.collectionView.frame) - SCHEDULE_PROMPT_HEIGHT;
                }
                _schedulePromptView.frame = CGRectMake(_schedulePromptView.frame.origin.x, pointY, SCHEDULE_PROMPT_WIDTH, SCHEDULE_PROMPT_HEIGHT);

            }
        }
        
        if (j >=0 && (count_X < ONE_DAY_NUMBER)) {
            if (j != _startPointX || count_X != _currentPointX) {
                _startPointX = j;
                _currentPointX = count_X;
                
                NSString *timeString = [NSString stringWithFormat:@"%@:%d:00-%d:00", NSLocalizedString(@"mcs_time", nil), j, count_X+1];

                [_schedulePromptView setScheduleWeek:nil Time:timeString];
                
                CGFloat pointX = j*(CGRectGetWidth(self.collectionView.frame))/ONE_DAY_NUMBER;
                if (pointX < 0) {
                    pointX = 0;
                } else if (pointX > CGRectGetWidth(self.collectionView.frame) - SCHEDULE_PROMPT_WIDTH) {
                    pointX = CGRectGetWidth(self.collectionView.frame) - SCHEDULE_PROMPT_WIDTH;
                }
                _schedulePromptView.frame = CGRectMake(pointX, _schedulePromptView.frame.origin.y, SCHEDULE_PROMPT_WIDTH, SCHEDULE_PROMPT_HEIGHT);

            }
        }
    }
    else if (gestureRecongnizer.state == UIGestureRecognizerStateEnded)
    {
        _endPoint = currentPoint;
        _schedulePromptView.hidden = YES;
        
        if (_scheduleSceneSetView) {
            _scheduleSceneSetView.hidden = NO;
        } else {
            _scheduleSceneSetView = [[[NSBundle mainBundle] loadNibNamed:@"MNScheduleSceneSetView" owner:self options:nil] lastObject];
            _scheduleSceneSetView.frame = [UIScreen mainScreen].bounds;
            _scheduleSceneSetView.delegate = self;
            [self.app.window addSubview:_scheduleSceneSetView];
        }
        
        _startPointX = -1;
        _startPointY = -1;
        _currentPointX = -1;
        _currentPointY = -1;
    }
    else
    {
        //dismiss all
        _schedulePromptView.hidden = YES;
        
        _startPointX = -1;
        _startPointY = -1;
        _currentPointX = -1;
        _currentPointY = -1;
    }
}

@end
