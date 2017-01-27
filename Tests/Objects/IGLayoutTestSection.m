// Copyright 2004-present Facebook. All Rights Reserved.

#import "IGLayoutTestSection.h"

@implementation IGLayoutTestSection

- (instancetype)initWithInsets:(UIEdgeInsets)insets
                   lineSpacing:(CGFloat)lineSpacing
              interitemSpacing:(CGFloat)interitemSpacing
                  headerHeight:(CGFloat)headerHeight
                         items:(NSArray<IGLayoutTestItem *> *)items {
    if (self = [super init]) {
        _insets = insets;
        _lineSpacing = lineSpacing;
        _interitemSpacing = interitemSpacing;
        _headerHeight = headerHeight;
        _items = [items copy];
    }
    return self;
}

@end
