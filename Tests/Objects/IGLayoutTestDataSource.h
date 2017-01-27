// Copyright 2004-present Facebook. All Rights Reserved.

#import <UIKit/UIKit.h>

@class IGLayoutTestSection;

@interface IGLayoutTestDataSource : NSObject <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, strong) NSArray<IGLayoutTestSection *> *sections;

// call before using as the data source so cells and headers are configured
- (void)configCollectionView:(UICollectionView *)collectionView;

@end
