//
//  ABTileViewController.m
//  DailyPhoto
//
//  Created by Антон Буков on 30.11.13.
//  Copyright (c) 2013 Codeless Solution. All rights reserved.
//

#import "ABTileViewController.h"
#import "ABPhotoViewController.h"
#import "NSXMLParser+Laconic.h"
#import "UIImage+DecompressAndMap.h"
#import "ABDataDiskCache.h"
#import "NSData+FetchDataOnce.h"

#define LOOP_FIRST_RSS_RESULT

const NSInteger imageViewTag = 101;

@interface ABTileViewController () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) NSMutableDictionary *tileDict;
@property (strong, nonatomic) ABDataDiskCache *thumbnailCache;
@property (strong, nonatomic) ABDataDiskCache *photoCache;
@property (strong, nonatomic) NSString *nextPageUrl;
@property (strong, nonatomic) ABPhotoViewController *photoViewController;
@property (strong, nonatomic) NSMutableSet *urlsInProgress;

@end

@implementation ABTileViewController

#pragma mark - Properties

- (NSMutableArray *)items
{
    if (_items == nil)
        _items = [NSMutableArray array];
    return _items;
}

- (NSMutableDictionary *)tileDict
{
    if (_tileDict == nil)
        _tileDict = [NSMutableDictionary dictionary];
    return _tileDict;
}

- (ABDataDiskCache *)thumbnailCache
{
    if (_thumbnailCache == nil)
    {
        NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
        _thumbnailCache = [[ABDataDiskCache alloc] initWithPath:cachePath];
    }
    return _thumbnailCache;
}

- (ABDataDiskCache *)photoCache
{
    if (_photoCache == nil)
    {
        NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
        _photoCache = [[ABDataDiskCache alloc] initWithPath:cachePath];
    }
    return _photoCache;
}

- (ABPhotoViewController *)photoViewController
{
    if (_photoViewController == nil)
    {
        _photoViewController = [[ABPhotoViewController alloc] init];
        _photoViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    return _photoViewController;
}

- (NSMutableSet *)urlsInProgress
{
    if (_urlsInProgress == nil)
        _urlsInProgress = [NSMutableSet set];
    return _urlsInProgress;
}

#pragma mark - Collection View

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
#ifdef LOOP_FIRST_RSS_RESULT
    return self.items.count * 1000;
#else
    return self.items.count;
#endif
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        return CGSizeMake(128,128);
    return CGSizeMake(40,40);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (void)tileShowAnimation:(UIView *)tileView
{
    tileView.alpha = 0.0;
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseInOut)
                     animations:^{
                         tileView.alpha = 1.0;
                     } completion:nil];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell_photo" forIndexPath:indexPath];
    
    UIImageView *imageView;
    
    if (cell.contentView.subviews.count == 0) {
        imageView = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
        imageView.contentMode = UIViewContentModeCenter;//ScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.tag = imageViewTag;
        [cell.contentView addSubview:imageView];
    } else {
        imageView = (id)[cell.contentView viewWithTag:imageViewTag];
    }
    
    NSString *urlStr = self.items[indexPath.item%self.items.count][@"media:thumbnail"][@"url"];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]
                      stringByAppendingPathComponent:[NSString stringWithFormat:@"%lu-%d-%d",
                                                      (unsigned long)[urlStr hash],
                                                      (int)[urlStr length],
                                                      (int)[self collectionView:nil
                                                                         layout:nil
                                                         sizeForItemAtIndexPath:nil].width]];
    imageView.image = [self.tileDict objectForKey:urlStr];
    if (imageView.image == nil) {
        imageView.image = [UIImage imageMapFromPath:path];
        if (imageView.image)
            [self.tileDict setObject:imageView.image forKey:urlStr];
    }
    
    if (imageView.image)
        [self tileShowAnimation:imageView];
    
    if (!imageView.image || ![self.thumbnailCache objectForKey:urlStr]) {
        NSData *data = [self.thumbnailCache objectForKey:urlStr];
        if (data == nil)
        {
            [NSData fetchFromURL:[NSURL URLWithString:urlStr]
                         toBlock:^(NSData *data, BOOL *retry) {
                             if (data == nil) {
                                 *retry = YES;
                                 return;
                             }
                             
                             UIImage *image = [UIImage imageWithData:data];
                             CGFloat w = MIN(image.size.width, image.size.height);
                             image = [image decompressAndMapToPath:path
                                                          withCrop:CGRectMake((image.size.width-w)/2,
                                                                              (image.size.height-w)/2,w,w)
                                                         andResize:[self collectionView:nil
                                                                                 layout:nil
                                                                 sizeForItemAtIndexPath:nil]];
                             if (image == nil)
                                 return;
                             
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 UICollectionViewCell * cell = [collectionView cellForItemAtIndexPath:indexPath];
                                 UIImageView *imageView = (id)[cell.contentView viewWithTag:imageViewTag];
                                 BOOL needToShow = (imageView.image == nil);
                                 imageView.image = image;
                                 [self.thumbnailCache setObject:data forKey:urlStr];
                                 [self.tileDict setObject:image forKey:urlStr];
                                 if (needToShow)
                                     [self tileShowAnimation:imageView];
                             });
                         }];
        }
    }
    
#ifndef LOOP_FIRST_RSS_RESULT
    if (indexPath.item == self.items.count - 1) {
        [self loadPageUrl:self.nextPageUrl
                 nextPage:^(NSString *nextPageUrl) {
                     self.nextPageUrl = nextPageUrl;
                 }];
    }
#endif
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    NSString *miniUrlStr = self.items[indexPath.item%self.items.count][@"media:thumbnail"][@"url"];
    UIView * v = [collectionView cellForItemAtIndexPath:indexPath].contentView;
    self.photoViewController.currentIndexPath = indexPath;
    self.photoViewController.miniFrame = [v convertRect:v.bounds toView:self.view];
    self.photoViewController.miniImage = [UIImage imageWithData:[self.thumbnailCache objectForKey:miniUrlStr]];
    
    NSString *urlStr = self.items[indexPath.item%self.items.count][@"media:content"][@"url"];
    self.photoViewController.fullImage = [UIImage imageWithData:[self.thumbnailCache objectForKey:urlStr]];
    
    NSData *data = [self.photoCache objectForKey:urlStr];
    if (data == nil)
    {
        [NSData fetchFromURL:[NSURL URLWithString:urlStr]
                     toBlock:^(NSData *data, BOOL *retry) {
                         if (data == nil) {
                             NSLog(@"Repeating loading url: %@", urlStr);
                             *retry = YES;
                             return;
                         }
                         
                         UIImage *image = [UIImage imageWithData:data];
                         if (image == nil)
                             return;
                         
                         dispatch_async(dispatch_get_main_queue(), ^{
                             if ([self.photoViewController.currentIndexPath isEqual:indexPath])
                                 self.photoViewController.fullImage = image;
                             [self.photoCache setObject:data forKey:urlStr];
                         });
                     }];
    }
    
    [self presentViewController:self.photoViewController animated:YES completion:nil];
}

#pragma mark - UIView

- (void)loadPageUrl:(NSString *)urlStr nextPage:(void(^)(NSString *))nextPage
{
    [NSData fetchFromURL:[NSURL URLWithString:urlStr]
                 toBlock:^(NSData *data, BOOL *retry) {
                     if (data == nil) {
                         NSLog(@"Repeating loading url: %@", urlStr);
                         *retry = YES;
                         return;
                     }
                     
                     NSError *error;
                     id xml = [NSXMLParser XMLObjectWithData:data error:&error];
                     if (error) {
                         NSLog(@"Error loading rss: %@", error);
                         return;
                     }
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         if (nextPage)
                             nextPage(xml[@"rss"][@"channel"][@"atom:link"][@"href"]);
                         
                         NSMutableArray *indexPaths = [NSMutableArray array];
                         BOOL insertToFront = [urlStr rangeOfString:@"?"].location == NSNotFound;
                         int frontIndex = 0;
                         for (id item in xml[@"rss"][@"channel"][@"item"]) {
                             if (item[@"media:thumbnail"][@"url"] == nil
                                 || item[@"media:content"][@"url"] == nil)
                                 continue;
                             
                             if (insertToFront && (self.items.count > 0)
                                 && [item[@"media:thumbnail"][@"url"] isEqualToString:self.items[0][@"media:thumbnail"][@"url"]])
                                 break;
                             
                             NSUInteger index = insertToFront ? frontIndex++ : self.items.count;
                             [indexPaths addObject:[NSIndexPath indexPathForItem:index inSection:0]];
                             [self.items insertObject:item atIndex:index];
                         }
                         
                         if (indexPaths.count > 0)
                         {
#ifdef LOOP_FIRST_RSS_RESULT
                             [self.collectionView reloadData];
#else
                             [self.collectionView performBatchUpdates:^{
                                 [self.collectionView insertItemsAtIndexPaths:indexPaths];
                             } completion:^(BOOL finished) {
                                 ;
                             }];
#endif
                         }
                     });
                 }];
}

- (void)refershControlAction:(id)sender
{
    [self loadPageUrl:@"http://fotki.yandex.ru/calendar/rss2"
             nextPage:^(NSString *nextPageUrl) {
                 self.nextPageUrl = nextPageUrl;
                 [self.refreshControl endRefreshing];
             }];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)setup
{
    NSArray *items = [[NSUserDefaults standardUserDefaults] objectForKey:@"Items"];
    if (items)
    {
        self.items = [items mutableCopy];
        [self.collectionView reloadData];
    }
    
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell_photo"];
    [self loadPageUrl:@"http://fotki.yandex.ru/calendar/rss2"
             nextPage:^(NSString *nextPageUrl) {
                 self.nextPageUrl = nextPageUrl;
             }];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(refershControlAction:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    self.collectionView.alwaysBounceVertical = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
}

- (void)appWillTerminate:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:self.items forKey:@"Items"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self setup];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
