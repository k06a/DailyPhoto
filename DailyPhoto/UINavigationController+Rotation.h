//
//  ABBetterNavigationController.h
//  DailyPhoto
//
//  Created by Антон Буков on 01.12.13.
//  Copyright (c) 2013 Codeless Solution. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (Rotation)

- (BOOL)shouldAutorotate;
- (NSUInteger)supportedInterfaceOrientations;
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation;

@end
