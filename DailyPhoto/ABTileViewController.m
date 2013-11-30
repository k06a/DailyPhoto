//
//  ABTileViewController.m
//  DailyPhoto
//
//  Created by Антон Буков on 30.11.13.
//  Copyright (c) 2013 Codeless Solution. All rights reserved.
//

#import "ABTileViewController.h"
#import "NSXMLParser+Laconic.h"

@interface ABTileViewController () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) NSMutableDictionary *imageCache;

@end

@implementation ABTileViewController

#pragma mark - Properties

- (NSMutableArray *)items
{
    if (_items == nil)
        _items = [NSMutableArray array];
    return _items;
}

- (NSMutableDictionary *)imageCache
{
    if (_imageCache == nil)
        _imageCache = [NSMutableDictionary dictionary];
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
    return CGSizeMake(self.view.bounds.size.width/4,
                      self.view.bounds.size.width/4);
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
    imageView.image = self.imageCache[url];
    
    if (imageView.image) {
        [self tileShowAnimation:imageView];
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
            if (image == nil)
                return;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UICollectionViewCell * cell = [collectionView cellForItemAtIndexPath:indexPath];
                UIImageView *imageView = (id)[cell.contentView viewWithTag:imageViewTag];
                imageView.image = image;
                self.imageCache[url] = image;
                [self tileShowAnimation:imageView];
            });
        });
    }
    
    return cell;
}

#pragma mark - UIView

- (void)setup
{
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell_photo"];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:@"http://fotki.yandex.ru/calendar/rss2"];
        NSData *data = [NSData dataWithContentsOfURL:url];
        NSError *error;
        id xml = [NSXMLParser XMLObjectWithData:data error:&error];
        if (error) {
            NSLog(@"Error loading rss: %@", error);
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.items addObjectsFromArray:xml[@"rss"][@"channel"][@"item"]];
            [self.collectionView reloadData];
        });
    });
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
