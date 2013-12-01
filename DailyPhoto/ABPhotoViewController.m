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
@property (strong, nonatomic) UIImageView *imageView2;

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
    self.imageView2.image = fullImage;
}

- (void)tap:(id)sender
{
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:(UIViewAnimationOptionBeginFromCurrentState|
                                 UIViewAnimationOptionCurveEaseInOut)
                     animations:^{
                         self.view.backgroundColor = [UIColor clearColor];
                         self.imageView.transform = CGAffineTransformIdentity;
                         self.imageView2.transform = CGAffineTransformIdentity;
                     } completion:^(BOOL finished) {
                         self.imageView.hidden = NO;
                         self.imageView2.hidden = YES;
                         [self dismissViewControllerAnimated:NO completion:nil];
                     }];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
/*
+ (void)flipFromView:(UIView *)fromView toView:(UIView *)toView
{
    [fromView.superview addSubview:toView];
    
    //ready to transform
    toView.transform = CGAffineTransformMake(0, 0, 0, 1, 0, 0);
    
    [UIView animateWithDuration:0.4 animations:^{
        //fromView disappear with flip 90º
        fromView.transform = CGAffineTransformMake(0, 0, 0, 1, 0, 0);
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:0.4 animations:^{
            //toView appear with flip 90º
			toView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
        } completion:^(BOOL finished) {
            [fromView removeFromSuperview];
		}];
    }];
}
*/
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /*
    [UIView transitionFromView:self.imageView
                        toView:self.imageView2
                      duration:0.4
                       options:(UIViewAnimationOptionBeginFromCurrentState|
                                UIViewAnimationOptionTransitionNone)
                    completion:^(BOOL finished) {
                        ;
                    }];
    */
    
    CGFloat w = MIN(self.view.bounds.size.width, self.view.bounds.size.height);
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:(UIViewAnimationOptionBeginFromCurrentState|
                                 UIViewAnimationOptionCurveEaseInOut)
                     animations:^{
                         self.view.backgroundColor = [UIColor blackColor];
                         CGAffineTransform trans = CGAffineTransformScale(
                                                        CGAffineTransformMakeTranslation(
                                                            CGRectGetMidX(self.view.bounds) - CGRectGetMidX(self.miniFrame),
                                                            CGRectGetMidY(self.view.bounds) - CGRectGetMidY(self.miniFrame)),
                                                        w/self.miniFrame.size.width,
                                                        w/self.miniFrame.size.width);
                         self.imageView.transform = trans;
                         self.imageView2.transform = trans;
                     } completion:^(BOOL finished) {
                         self.imageView.hidden = YES;
                         self.imageView2.hidden = NO;
                     }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.blackView.frame = self.miniFrame;
    self.imageView.frame = self.miniFrame;
    self.imageView.image = self.miniImage;
    self.imageView2.frame = self.miniFrame;
    self.imageView2.image = self.fullImage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.view.backgroundColor = [UIColor clearColor];
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer:self.tapRecognizer];
    
    self.blackView = [[UIView alloc] initWithFrame:self.miniFrame];
    self.blackView.backgroundColor = [UIColor blackColor];
    self.imageView = [[UIImageView alloc] initWithFrame:self.miniFrame];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    self.imageView2 = [[UIImageView alloc] initWithFrame:self.miniFrame];
    self.imageView2.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView2.clipsToBounds = YES;
    
    [self.view addSubview:self.blackView];
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.imageView2];
    self.imageView2.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end