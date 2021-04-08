//
//  CuteView.m
//  BJZApp
//
//  Created by rockfintech on 2021/4/7.
//  Copyright © 2021 kedll. All rights reserved.
//
//果冻效果页面
#import "CuteView.h"
#define MIN_HEIGHT          150
#define appWidth CGRectGetWidth([[UIScreen mainScreen] bounds])
#define appHight CGRectGetHeight([[UIScreen mainScreen] bounds])
@interface CuteView ()

@property (nonatomic, assign) CGFloat mHeight;
@property (nonatomic, assign) CGFloat curveX;
@property (nonatomic, assign) CGFloat curveY;
@property (nonatomic, strong) UIView *curveView;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) BOOL isAnimating;


@end
@implementation CuteView

static NSString *kX = @"curveX";
static NSString *kY = @"curveY";


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addObserver:self forKeyPath:kX options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:kY options:NSKeyValueObservingOptionNew context:nil];
        [self configShapeLayer];
        [self configCurveView];
        [self configAction];
        [self changeShape];
    }
    return self;
}

-(void)dealloc{
    [self removeObserver:self forKeyPath:kX];
    [self removeObserver:self forKeyPath:kY];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:kX]||[keyPath isEqualToString:kY]) {
        
        [self updateShapeLayerPath];
    }
    
}


- (void)configAction
{
    _mHeight = 150;//手势移动的相对高度
    _isAnimating = NO;//是否处于动效状态
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanAction:)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:pan];
    //CADisplayLink默认每秒运行60次calculatePath是算出在运行期间_curveView的坐标，从而确定_shapeLayer的形状
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(calculatePath)];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    _displayLink.paused = YES;
}

- (void)configShapeLayer
{
    _shapeLayer = [CAShapeLayer layer];
    [self.layer addSublayer:_shapeLayer];
    _headerImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
    _headerImage.layer.cornerRadius = 40;
    _headerImage.clipsToBounds = YES;
    _headerImage.backgroundColor = [UIColor blueColor];
    [self addSubview:_headerImage];
    _headerImage.center = CGPointMake(appWidth/2, 105);
    
}

- (void)changeShape
{
    //更新shapLayer形状
    UIBezierPath * tpath = [UIBezierPath bezierPath];
    //移动起始点
    [tpath moveToPoint:CGPointMake(0, 0)];
 //底部直线
    [tpath addLineToPoint:CGPointMake(appWidth, 0)];
    
    [tpath addLineToPoint:CGPointMake(appWidth, 150)];
      
    //结束点和控制点
    [tpath addQuadCurveToPoint:CGPointMake(0, 150) controlPoint:CGPointMake(appWidth/2, 60)];
    [tpath closePath];
    
    _shapeLayer.path = tpath.CGPath;
    _shapeLayer.fillColor = [UIColor colorWithRed:0.85f green:0.96f blue:0.86f alpha:1.00f].CGColor;

}


- (void)configCurveView
{
    self.curveX = appWidth/2.0;
    self.curveY = MIN_HEIGHT;
    _curveView = [[UIView alloc]initWithFrame:CGRectMake(_curveX, 60, 0.1, 0.1)];
    _curveView.backgroundColor = [UIColor blackColor];
    [self addSubview:_curveView];
}

- (void)handlePanAction:(UIPanGestureRecognizer *)pan
{
    CGPoint point = [pan translationInView:self];
    if (point.y < 0) {
        return;
    }
    if (!_isAnimating) {//动画没有启动
        if (pan.state == UIGestureRecognizerStateChanged) {//手指移动时
            //手势移动时，_shapeLayer跟着手势向下扩大区域
            _mHeight = point.y+60;
            self.curveX = appWidth/2.0;
            self.curveY = _mHeight>240?240:_mHeight;
            _curveView.frame = CGRectMake(_curveX, self.curveY, _curveView.frame.size.width, _curveView.frame.size.height);
            _headerImage.center = CGPointMake(appWidth/2, 105+(self.curveY-60)/2);
            [self.cuteDelegate backMeWithHeaderCenterY:105 + (self.curveY - 60) / 2];
        }   else if (pan.state == UIGestureRecognizerStateCancelled ||pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateFailed){
            // 手势结束时,_shapeLayer返回原状并产生弹簧动效
            _isAnimating = YES;
            _displayLink.paused = NO;           //开启displaylink,会执行方法calculatePath.
            // 弹簧动效
            [UIView animateWithDuration:1
                                  delay:0.0
                 usingSpringWithDamping:0.3
                  initialSpringVelocity:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 
                                 _curveView.frame = CGRectMake(appWidth/2, 60, 0.1, 0.1);
                                 _headerImage.center = CGPointMake(appWidth / 2, 105);
                                 NSLog(@"%f",_headerImage.center.y);

                                 [self.cuteDelegate backMeWithHeaderCenterY:105];

                             } completion:^(BOOL finished) {
                                 
                                 if(finished)
                                 {
                                     _displayLink.paused = YES;
                                     _isAnimating = NO;
                                     [self.cuteDelegate backMeWithHeaderCenterY:1000];

                                 }
                                 
                             }];
        }
        
    }
    
}

- (void)updateShapeLayerPath
{
    // 更新_shapeLayer形状
    UIBezierPath *tPath = [UIBezierPath bezierPath];
    [tPath moveToPoint:CGPointMake(0, 0)];
    [tPath addLineToPoint:CGPointMake(appWidth, 0)];
    [tPath addLineToPoint:CGPointMake(appWidth,  MIN_HEIGHT)];
    [tPath addQuadCurveToPoint:CGPointMake(0, MIN_HEIGHT)
                  controlPoint:CGPointMake(_curveX, _curveY)];
    [tPath closePath];
    _shapeLayer.path = tPath.CGPath;
    
}
- (void)calculatePath
{
    // 由于手势结束时,r5执行了一个UIView的弹簧动画,把这个过程的坐标记录下来,并相应的画出_shapeLayer形状
    CALayer *layer = _curveView.layer.presentationLayer;
    self.curveX = layer.position.x ;
    self.curveY = layer.position.y;
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
