// Copyright 2004-present Facebook. All Rights Reserved.

#import <UIKit/UIKit.h>

@class IGLayoutTestItem;

@interface IGLayoutTestSection : NSObject

@property (nonatomic, assign, readonly) UIEdgeInsets insets;
@property (nonatomic, assign, readonly) CGFloat lineSpacing;
@property (nonatomic, assign, readonly) CGFloat interitemSpacing;
@property (nonatomic, assign, readonly) CGFloat headerHeight;
@property (nonatomic, strong, readonly) NSArray<IGLayoutTestItem *> *items;

- (instancetype)initWithInsets:(UIEdgeInsets)insets
                   lineSpacing:(CGFloat)lineSpacing
              interitemSpacing:(CGFloat)interitemSpacing
                  headerHeight:(CGFloat)headerHeight
                         items:(NSArray<IGLayoutTestItem *> *)items;

@end
