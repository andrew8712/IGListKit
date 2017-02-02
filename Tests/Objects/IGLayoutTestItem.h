/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

@interface IGLayoutTestItem : NSObject

@property (nonatomic, assign, readonly) CGSize size;
@property (nonatomic, assign, readonly) BOOL expensive;

- (instancetype)initWithSize:(CGSize)size expensive:(BOOL)expensive;

@end