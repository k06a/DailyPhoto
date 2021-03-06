//
//  ABPhotoViewController.h
//  DailyPhoto
//
//  Created by Антон Буков on 01.12.13.
//  Copyright (c) 2013 Codeless Solution. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ABPhotoViewController : UIViewController

@property (strong, nonatomic) NSIndexPath *currentIndexPath;
@property (assign, nonatomic) CGRect miniFrame;
@property (strong, nonatomic) UIImage *miniImage;
@property (strong, nonatomic) UIImage *fullImage;

@property (strong, nonatomic) NSString *photoTitle;
@property (strong, nonatomic) NSString *photoAuthor;

@end
