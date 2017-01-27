// Copyright 2004-present Facebook. All Rights Reserved.

#import <UIKit/UIKit.h>

@interface IGLayoutTestItem : NSObject

@property (nonatomic, assign, readonly) CGSize size;
@property (nonatomic, assign, readonly) BOOL expensive;

- (instancetype)initWithSize:(CGSize)size expensive:(BOOL)expensive;

@end
