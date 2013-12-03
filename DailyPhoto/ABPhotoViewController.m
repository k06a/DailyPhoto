//
//  ABPhotoViewController.m
//  DailyPhoto
//
//  Created by Антон Буков on 01.12.13.
//  Copyright (c) 2013 Codeless Solution. All rights reserved.
//

#import "ABPhotoViewController.h"

@interface ABPhotoViewController ()

@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;
@property (strong, nonatomic) UIView *blackView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *authorLabel;

@end

@implementation ABPhotoViewController

@synthesize fullImage = _fullImage;

- (UIImage *)fullImage
{
    if (_fullImage == nil)
        return _miniImage;
    return _fullImage;
}

- (void)setFullImage:(UIImage *)fullImage
{
    _fullImage = fullImage;
    self.imageView.image = fullImage;
}

- (void)tap:(id)sender
{
    CAKeyframeAnimation *firstHalfBackFlip = [self animationFromTrans:[self endOfSecondHalfTransform]
                                                              toTrans:[self startOfSecondHalfTransform]
                                                           timingFunc:kCAMediaTimingFunctionEaseIn];
    [firstHalfBackFlip setValue:@"firstHalfBackFlip" forKey:@"FlipType"];
    firstHalfBackFlip.beginTime = CACurrentMediaTime() + 0.15;
    
    CAKeyframeAnimation *secondHalfBackFlip = [self animationFromTrans:[self endOfFirstHalfTransform]
                                                               toTrans:[self startOfFirstHalfTransform]
                                                            timingFunc:kCAMediaTimingFunctionEaseOut];
    [secondHalfBackFlip setValue:@"secondHalfFlip" forKey:@"FlipType"];
    secondHalfBackFlip.beginTime = CACurrentMediaTime() + 0.15 + firstHalfBackFlip.duration;
    
    secondHalfBackFlip.removedOnCompletion = NO;
    secondHalfBackFlip.delegate = self;

    [self.imageView.layer addAnimation:firstHalfBackFlip forKey:@"FirstHalfBackFlip"];
    [self.imageView.layer addAnimation:secondHalfBackFlip forKey:@"SecondHalfBackFlip"];
    
    self.titleLabel.alpha = 1.0;
    self.authorLabel.alpha = 1.0;
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseInOut)
                     animations:^{
                         self.titleLabel.alpha = 0.0;
                         self.authorLabel.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.4
                                               delay:0.0
                                             options:(UIViewAnimationOptionCurveEaseInOut)
                                          animations:^{
                                              self.view.backgroundColor = [UIColor clearColor];
                                          } completion:^(BOOL finished) {
                                              [self dismissViewControllerAnimated:NO completion:nil];
                                          }];
                     }];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (anim == [self.imageView.layer animationForKey:@"SecondHalfFlip"])
    {
        [self.imageView.layer removeAnimationForKey:@"SecondHalfFlip"];
        self.imageView.layer.transform = [self endOfSecondHalfTransform];
        /*
        CGFloat w = MIN(self.view.bounds.size.width, self.view.bounds.size.height);
        self.imageView.transform = CGAffineTransformScale(
                                        CGAffineTransformMakeTranslation(
                                            CGRectGetMidX(self.view.bounds) - CGRectGetMidX(self.miniFrame),
                                            CGRectGetMidY(self.view.bounds) - CGRectGetMidY(self.miniFrame)),
                                        w/self.miniFrame.size.width,
                                        w/self.miniFrame.size.width);
        */
        return;
    }
    
    if (anim == [self.imageView.layer animationForKey:@"SecondHalfBackFlip"])
    {
        [self.imageView.layer removeAnimationForKey:@"SecondHalfBackFlip"];
        self.imageView.layer.transform = [self startOfFirstHalfTransform];
        /*
        self.imageView.transform = CGAffineTransformIdentity;
        */
        return;
    }
}

- (CGRect)createTransAndScaleRect
{
    CGFloat w = MIN(self.view.bounds.size.width, self.view.bounds.size.height);
    return CGRectMake(CGRectGetMidX(self.view.bounds) - CGRectGetMidX(self.miniFrame),
                      CGRectGetMidY(self.view.bounds) - CGRectGetMidY(self.miniFrame),
                      w/self.miniFrame.size.width,
                      w/self.miniFrame.size.width);
}

- (CATransform3D)startOfFirstHalfTransform
{
    return CATransform3DIdentity;
}

- (CATransform3D)endOfFirstHalfTransform
{
    BOOL ky = (self.currentIndexPath.item & 0x01) == 0 ? 1 : -1;
    BOOL kz = (self.currentIndexPath.item & 0x02) == 0 ? 1 : -1;
    CGRect transAndScaleRect = [self createTransAndScaleRect];
    return CATransform3DRotate(
                CATransform3DRotate(
                    CATransform3DScale(
                        CATransform3DMakeTranslation(transAndScaleRect.origin.x,
                                                     transAndScaleRect.origin.y, 1000),
                        transAndScaleRect.size.width,
                        transAndScaleRect.size.height, 1.0),
                    ky*90*M_PI/180.0, 0.0, 1.0, 0.0),
                kz*90*M_PI/180.0, 0.0, 0.0, 1.0);
}

- (CATransform3D)startOfSecondHalfTransform
{
    BOOL ky = (self.currentIndexPath.item & 0x01) == 0 ? 1 : -1;
    BOOL kz = (self.currentIndexPath.item & 0x02) == 0 ? 1 : -1;
    CGRect transAndScaleRect = [self createTransAndScaleRect];
    return CATransform3DRotate(
                CATransform3DRotate(
                    CATransform3DScale(
                        CATransform3DMakeTranslation(transAndScaleRect.origin.x,
                                                     transAndScaleRect.origin.y, 1000),
                        transAndScaleRect.size.width,
                        transAndScaleRect.size.height, 1.0),
                    -ky*90*M_PI/180.0, 0.0, 1.0, 0.0),
                -kz*90*M_PI/180.0, 0.0, 0.0, 1.0);
}

- (CATransform3D)endOfSecondHalfTransform
{
    CGRect transAndScaleRect = [self createTransAndScaleRect];
    return CATransform3DScale(
                CATransform3DMakeTranslation(transAndScaleRect.origin.x,
                                             transAndScaleRect.origin.y, 1000),
                transAndScaleRect.size.width,
                transAndScaleRect.size.height, 1.0);
}

- (CAKeyframeAnimation *)animationFromTrans:(CATransform3D)t1
                                    toTrans:(CATransform3D)t2
                                 timingFunc:(NSString *)timingFunc
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.values = @[[NSValue valueWithCATransform3D:t1],
                         [NSValue valueWithCATransform3D:t2]];
    animation.duration = 0.25;
    animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:timingFunc]];
    animation.fillMode = kCAFillModeForwards;
    
    return animation;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    CATransform3D perspective = CATransform3DIdentity;
    perspective.m34 = 1.0 / - 180.0;
    self.view.layer.transform = perspective;
    
    CAKeyframeAnimation *firstHalfFlip = [self animationFromTrans:[self startOfFirstHalfTransform]
                                                          toTrans:[self endOfFirstHalfTransform]
                                                       timingFunc:kCAMediaTimingFunctionEaseIn];
    [firstHalfFlip setValue:@"firstHalfFlip" forKey:@"FlipType"];
    firstHalfFlip.beginTime = CACurrentMediaTime();
    
    CAKeyframeAnimation *secondHalfFlip = [self animationFromTrans:[self startOfSecondHalfTransform]
                                                           toTrans:[self endOfSecondHalfTransform]
                                                        timingFunc:kCAMediaTimingFunctionEaseOut];
    [secondHalfFlip setValue:@"secondHalfFlip" forKey:@"FlipType"];
    secondHalfFlip.beginTime = CACurrentMediaTime() + firstHalfFlip.duration;
    
    secondHalfFlip.removedOnCompletion = NO;
    secondHalfFlip.delegate = self;

    [self.imageView.layer addAnimation:firstHalfFlip forKey:@"FirstHalfFlip"];
    [self.imageView.layer addAnimation:secondHalfFlip forKey:@"SecondHalfFlip"];

    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseInOut)
                     animations:^{
                         self.view.backgroundColor = [UIColor blackColor];
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2
                                               delay:0.0
                                             options:(UIViewAnimationOptionCurveEaseInOut)
                                          animations:^{
                                              self.titleLabel.alpha = 1.0;
                                              self.authorLabel.alpha = 1.0;
                                          } completion:nil];
                     }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.blackView.frame = self.miniFrame;
    self.imageView.frame = self.miniFrame;
    self.imageView.image = self.fullImage ?: self.miniImage;
    self.imageView.transform = CGAffineTransformIdentity;
    self.titleLabel.text = self.photoTitle;
    self.authorLabel.text = [@"by " stringByAppendingString:self.photoAuthor];
    self.titleLabel.alpha = 0.0;
    self.authorLabel.alpha = 0.0;
    self.titleLabel.layer.transform = CATransform3DMakeTranslation(0,0,2000);
    self.authorLabel.layer.transform = CATransform3DMakeTranslation(0,0,2000);
    
    CGFloat w = MIN(self.view.bounds.size.width, self.view.bounds.size.height);
    self.titleLabel.frame = CGRectMake((self.view.bounds.size.width-w)/2 + w*0.05,
                                       (self.view.bounds.size.height-w)/2 + w*8.2/10, w*0.9, w/10);
    self.authorLabel.frame = CGRectMake((self.view.bounds.size.width-w)/2 + w*0.05,
                                        (self.view.bounds.size.height-w)/2 + w*9.0/10, w*0.9, w/10);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.frame = [UIScreen mainScreen].bounds;
    self.view.backgroundColor = [UIColor clearColor];
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer:self.tapRecognizer];
    
    self.blackView = [[UIView alloc] initWithFrame:self.miniFrame];
    self.blackView.backgroundColor = [UIColor blackColor];
    self.imageView = [[UIImageView alloc] initWithFrame:self.miniFrame];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textAlignment = NSTextAlignmentRight;
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.shadowColor = [UIColor grayColor];
    self.titleLabel.shadowOffset = CGSizeMake(1,1);
    [self.titleLabel setMinimumScaleFactor:0.5];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        self.titleLabel.font = [UIFont systemFontOfSize:36];
    else
        self.titleLabel.font = [UIFont systemFontOfSize:24];
    
    self.authorLabel = [[UILabel alloc] init];
    self.authorLabel.numberOfLines = 0;
    self.authorLabel.backgroundColor = [UIColor clearColor];
    self.authorLabel.textAlignment = NSTextAlignmentRight;
    self.authorLabel.textColor = [UIColor whiteColor];
    self.authorLabel.shadowColor = [UIColor grayColor];
    self.authorLabel.shadowOffset = CGSizeMake(1,1);
    [self.authorLabel setMinimumScaleFactor:0.5];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        self.authorLabel.font = [UIFont italicSystemFontOfSize:36];
    else
        self.authorLabel.font = [UIFont italicSystemFontOfSize:24];
    
    self.imageView.autoresizingMask = UIViewAutoresizingNone;
    [self.view addSubview:self.blackView];
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.authorLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
