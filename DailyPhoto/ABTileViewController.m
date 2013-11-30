//
//  ABTileViewController.m
//  DailyPhoto
//
//  Created by Антон Буков on 30.11.13.
//  Copyright (c) 2013 Codeless Solution. All rights reserved.
//

#import "ABTileViewController.h"
#import "NSXMLParser+Laconic.h"
#import "ABDiskCache.h"
#import "UIImage+ImageWithDataNoCopy.h"

@interface ABTileViewController () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) ABDiskCache *imageCache;
@property (strong, nonatomic) NSString *nextPageUrl;

@end

@implementation ABTileViewController

#pragma mark - Properties

- (NSMutableArray *)items
{
    if (_items == nil)
        _items = [NSMutableArray array];
    return _items;
}

- (ABDiskCache *)imageCache
{
    if (_imageCache == nil)
        _imageCache = [[ABDiskCache alloc] init];
    return _imageCache;
}

#pragma mark - Collection View

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return self.items.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(64,64);
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
    [UIView animateWithDuration:0.2
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
    
    const NSInteger imageViewTag = 101;
    UIImageView *imageView;
    
    if (cell.contentView.subviews.count == 0) {
        imageView = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.tag = imageViewTag;
        [cell.contentView addSubview:imageView];
    } else {
        imageView = (id)[cell.contentView viewWithTag:imageViewTag];
    }
    
    NSURL *url = [NSURL URLWithString:self.items[indexPath.item][@"media:thumbnail"][@"url"]];
    NSData *data = [self.imageCache objectForKey:url];
    if (data)
        imageView.image = [UIImage imageWithDataNoCopy:data];
    
    if (imageView.image) {
        [self tileShowAnimation:imageView];
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *data = [NSData dataWithContentsOfURL:url];
            UIImage *image = [UIImage imageWithData:data];
            if (image == nil)
                return;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UICollectionViewCell * cell = [collectionView cellForItemAtIndexPath:indexPath];
                UIImageView *imageView = (id)[cell.contentView viewWithTag:imageViewTag];
                imageView.image = image;
                [self.imageCache setObject:UIImagePNGRepresentation([image decompressed]) forKey:url];
                [self tileShowAnimation:imageView];
            });
        });
    }
    
    if (indexPath.item == self.items.count - 1) {
        [self loadPageUrl:self.nextPageUrl
                 nextPage:^(NSString *nextPageUrl) {
                     self.nextPageUrl = nextPageUrl;
                 }];
    }
    
    return cell;
}

#pragma mark - UIView

- (void)loadPageUrl:(NSString *)urlStr nextPage:(void(^)(NSString *))nextPage
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:urlStr];
        NSData *data = [NSData dataWithContentsOfURL:url];
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
            for (id item in xml[@"rss"][@"channel"][@"item"]) {
                if (item[@"media:thumbnail"][@"url"]) {
                    [indexPaths addObject:[NSIndexPath indexPathForItem:self.items.count inSection:0]];
                    [self.items addObject:item];
                }
            }
            
            [self.collectionView performBatchUpdates:^{
                [self.collectionView insertItemsAtIndexPaths:indexPaths];
            } completion:^(BOOL finished) {
                ;
            }];
        });
    });
}

- (void)setup
{
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell_photo"];
    [self loadPageUrl:@"http://fotki.yandex.ru/calendar/rss2"
             nextPage:^(NSString *nextPageUrl) {
                 self.nextPageUrl = nextPageUrl;
             }];
}

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    if (self = [super initWithCollectionViewLayout:layout]) {
        [self setup];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
