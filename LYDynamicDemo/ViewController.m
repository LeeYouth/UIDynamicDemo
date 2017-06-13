//
//  ViewController.m
//  LYDynamicDemo
//
//  Created by CNFOL_iOS on 2017/6/13.
//  Copyright © 2017年 com.LYoung. All rights reserved.
//

#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>

@interface ViewController ()<UICollisionBehaviorDelegate>

@property (nonatomic, strong) NSMutableArray *balls;
@property (nonatomic, strong) UIGravityBehavior *gravityBeahvior;
@property (nonatomic, strong) UIGravityBehavior *gravity;
@property (nonatomic, strong) UICollisionBehavior *collision;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIDynamicItemBehavior *dynamicItemBehavior;
@property (nonatomic) CMMotionManager *MotionManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *clickBtn = [UIButton new];
    [clickBtn addTarget:self action:@selector(buttonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [clickBtn setBackgroundColor:[UIColor redColor]];
    [clickBtn setTitle:@"开始碰撞" forState:UIControlStateNormal];
    [clickBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:clickBtn];
    clickBtn.frame = CGRectMake((self.view.frame.size.width - 80)/2, 80, 80, 40);
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"head-back.jpg"]];

}

- (void)_setupBalls{
   
    
    
    self.balls = [NSMutableArray array];
    //添加两个球体，使用拥有重力特性和碰撞特性
    NSUInteger numOfBalls = 15;
    for (NSUInteger i = 0; i < numOfBalls; i ++) {
        
        UIImageView *ball = [UIImageView new];
        
        //球的随机颜色
        ball.image = [UIImage imageNamed:[NSString stringWithFormat:@"headIcon-%ld.jpg",i]];
        
        //球的随机大小:40~60之间
        CGFloat width = 44;
        ball.layer.cornerRadius = width/2;
        ball.layer.masksToBounds = YES;
        
        //球的随机位置
        CGRect frame = CGRectMake(arc4random()%((int)(self.view.bounds.size.width - width)), 0, width, width);
        [ball setFrame:frame];
        
        //添加球体到父视图
        [self.view addSubview:ball];
        //球堆添加该球
        [self.balls addObject:ball];
    }
    
    UIDynamicAnimator *animator     = [[UIDynamicAnimator alloc]initWithReferenceView:self.view];
    _animator                       = animator;
    
    //添加重力的动态特性，使其可执行
    UIGravityBehavior *gravity = [[UIGravityBehavior alloc]initWithItems:self.balls];
    [self.animator addBehavior:gravity];
    _gravity = gravity;
    
    //添加碰撞的动态特性，使其可执行
    UICollisionBehavior *collision = [[UICollisionBehavior alloc]initWithItems:self.balls];
    collision.translatesReferenceBoundsIntoBoundary = YES;
    [self.animator addBehavior:collision];
    _collision = collision;
    
    //弹性
    UIDynamicItemBehavior *dynamicItemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:self.balls];
    dynamicItemBehavior.allowsRotation = YES;//允许旋转
    dynamicItemBehavior.elasticity = 0.6;//弹性
    [self.animator addBehavior:dynamicItemBehavior];
}

- (void)buttonClickAction:(UIButton *)sender{
    sender.enabled = NO;
    [self _setupBalls];

}


- (void)useGyroPush{
    //初始化全局管理对象
    
    self.MotionManager = [[CMMotionManager alloc]init];
    self.MotionManager.deviceMotionUpdateInterval = 0.01;
    
    
    __weak ViewController *weakSelf = self;
    
    if (self.MotionManager.deviceMotionAvailable == YES && self.MotionManager.accelerometerAvailable == YES)
    {
        [self.MotionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion *_Nullable motion,NSError * _Nullable error) {
            
            NSString *yaw = [NSString stringWithFormat:@"%f",motion.attitude.yaw];
            NSString *pitch = [NSString stringWithFormat:@"%f",motion.attitude.pitch];
            NSString *roll = [NSString stringWithFormat:@"%f",motion.attitude.roll];
            
            double rotation = atan2(motion.attitude.pitch, motion.attitude.roll);
            
            //重力角度
            weakSelf.gravity.angle = rotation;
            
            NSLog(@"yaw = %@,pitch = %@, roll = %@,rotation = %fd",yaw,pitch,roll,rotation);
            
        }];
    }
    
    
}



#pragma mark - UICollisionBehaviorDelegate
- (void)collisionBehavior:(UICollisionBehavior*)behavior beganContactForItem:(id <UIDynamicItem>)item withBoundaryIdentifier:(nullable id <NSCopying>)identifier atPoint:(CGPoint)p {
    
}

- (void)collisionBehavior:(UICollisionBehavior*)behavior endedContactForItem:(id <UIDynamicItem>)item withBoundaryIdentifier:(nullable id <NSCopying>)identifier {
    
}

- (void)dealloc{
    NSLog(@"[dealloc]");
    [self.MotionManager stopDeviceMotionUpdates];
}
@end
