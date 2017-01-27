// Copyright 2004-present Facebook. All Rights Reserved.

#import "IGLayoutTestItem.h"

@implementation IGLayoutTestItem {
    CGSize _size;
}

- (instancetype)initWithSize:(CGSize)size expensive:(BOOL)expensive {
    if (self = [super init]) {
        _size = size;
        _expensive = expensive;
    }
    return self;
}

- (CGSize)size {
    if (self.expensive) {
        usleep(100); // 0.1 ms
    }
    return _size;
}

@end
