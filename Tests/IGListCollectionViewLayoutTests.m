/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <XCTest/XCTest.h>

#import <IGListKit/IGListCollectionViewLayout.h>

#import "IGLayoutTestDataSource.h"
#import "IGLayoutTestItem.h"
#import "IGLayoutTestSection.h"

@interface IGListCollectionViewLayoutTests : XCTestCase

@property (nonatomic, strong) IGListCollectionViewLayout *layout;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) IGLayoutTestDataSource *dataSource;

@end

static const CGRect kTestFrame = (CGRect){{0, 0}, {100, 100}};

static NSIndexPath *quickPath(NSInteger section, NSInteger item) {
    return [NSIndexPath indexPathForItem:item inSection:section];
}

#define IGAssertEqualFrame(frame, x, y, w, h, ...) \
do { \
CGRect expected = CGRectMake(x, y, w, h); \
XCTAssertEqual(CGRectGetMinX(expected), CGRectGetMinX(frame)); \
XCTAssertEqual(CGRectGetMinY(expected), CGRectGetMinY(frame)); \
XCTAssertEqual(CGRectGetWidth(expected), CGRectGetWidth(frame)); \
XCTAssertEqual(CGRectGetHeight(expected), CGRectGetHeight(frame)); \
} while(0)

@implementation IGListCollectionViewLayoutTests

- (UICollectionViewCell *)cellForSection:(NSInteger)section item:(NSInteger)item {
    return [self.collectionView cellForItemAtIndexPath:quickPath(section, item)];
}

- (UICollectionReusableView *)headerForSection:(NSInteger)section {
    return [self.collectionView supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:quickPath(section, 0)];
}

- (void)setUpWithStickyHeaders:(BOOL)sticky topInset:(CGFloat)inset {
    self.layout = [[IGListCollectionViewLayout alloc] initWithStickyHeaders:sticky topContentInset:inset];
    self.dataSource = [IGLayoutTestDataSource new];
    self.collectionView = [[UICollectionView alloc] initWithFrame:kTestFrame collectionViewLayout:self.layout];
    self.collectionView.dataSource = self.dataSource;
    self.collectionView.delegate = self.dataSource;
    [self.dataSource configCollectionView:self.collectionView];
}

- (void)tearDown {
    [super tearDown];

    self.collectionView = nil;
    self.layout = nil;
    self.dataSource = nil;
}

- (void)prepareWithData:(NSArray<IGLayoutTestSection *> *)data {
    self.dataSource.sections = data;
    [self.collectionView reloadData];
    [self.collectionView layoutIfNeeded];
}

- (void)test_thatContentSizeZero_withEmptyData {
    [self setUpWithStickyHeaders:YES topInset:0];

    [self prepareWithData:nil];

    // check so that nil messaging doesn't default size to 0
    XCTAssertEqual(self.layout.collectionView, self.collectionView);
    XCTAssertTrue(CGSizeEqualToSize(CGSizeZero, self.collectionView.contentSize));
}

- (void)test_contentSize_andCellFrame_withItemSizes_andHeaders_andLineSpacing_andSectionInsets {
    [self setUpWithStickyHeaders:NO topInset:0];

    const CGFloat headerHeight = 10;
    const CGFloat lineSpacing = 10;
    const UIEdgeInsets insets = UIEdgeInsetsMake(10, 10, 5, 5);

    [self prepareWithData:@[
                            [[IGLayoutTestSection alloc] initWithInsets:insets
                                                      lineSpacing:lineSpacing
                                                 interitemSpacing:0
                                                     headerHeight:headerHeight
                                                            items:@[
                                                                    [[IGLayoutTestItem alloc] initWithSize:(CGSize){85,10} expensive:NO],
                                                                    [[IGLayoutTestItem alloc] initWithSize:(CGSize){85,20} expensive:NO],
                                                                    ]],
                            [[IGLayoutTestSection alloc] initWithInsets:insets
                                                      lineSpacing:lineSpacing
                                                 interitemSpacing:0
                                                     headerHeight:headerHeight
                                                            items:@[
                                                                    [[IGLayoutTestItem alloc] initWithSize:(CGSize){85,30} expensive:NO],
                                                                    ]],
                            ]];
    XCTAssertEqual(self.collectionView.contentSize.height, 120);
    IGAssertEqualFrame([self headerForSection:0].frame, 10, 10, 85, 10);
    IGAssertEqualFrame([self cellForSection:0 item:0].frame, 10, 20, 85, 10);
    IGAssertEqualFrame([self cellForSection:0 item:1].frame, 10, 40, 85, 20);
    IGAssertEqualFrame([self headerForSection:1].frame, 10, 75, 85, 10);
    IGAssertEqualFrame([self cellForSection:1 item:0].frame, 10, 85, 85, 30);
}

- (void)test_stickyHeaders_afterScrolling {
    [self setUpWithStickyHeaders:YES topInset:10];

    [self prepareWithData:@[
                            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                                      lineSpacing:0
                                                 interitemSpacing:0
                                                     headerHeight:10
                                                            items:@[
                                                                    [[IGLayoutTestItem alloc] initWithSize:(CGSize){100,20} expensive:NO],
                                                                    [[IGLayoutTestItem alloc] initWithSize:(CGSize){100,20} expensive:NO],
                                                                    ]],
                            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                                      lineSpacing:0
                                                 interitemSpacing:0
                                                     headerHeight:10
                                                            items:@[
                                                                    [[IGLayoutTestItem alloc] initWithSize:(CGSize){100,30} expensive:NO],
                                                                    [[IGLayoutTestItem alloc] initWithSize:(CGSize){100,30} expensive:NO],
                                                                    [[IGLayoutTestItem alloc] initWithSize:(CGSize){100,30} expensive:NO],
                                                                    ]],
                            ]];

    // scroll header 0 halfway
    self.collectionView.contentOffset = CGPointMake(0, 5);
    [self.collectionView layoutIfNeeded];
    IGAssertEqualFrame([self headerForSection:0].frame, 0, 15, 100, 10);
    IGAssertEqualFrame([self headerForSection:1].frame, 0, 50, 100, 10);

    // scroll header 0 off and 1 up
    self.collectionView.contentOffset = CGPointMake(0, 45);
    [self.collectionView layoutIfNeeded];
    IGAssertEqualFrame([self headerForSection:0].frame, 0, 40, 100, 10);
    IGAssertEqualFrame([self headerForSection:1].frame, 0, 55, 100, 10);
}

- (void)test_whenItemsSmallerThanContainerWidth_with0Insets_with0LineSpacing_with0Interitem_thatItemsFitSameRow {
    [self setUpWithStickyHeaders:NO topInset:0];

    [self prepareWithData:@[
                            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                                      lineSpacing:0
                                                 interitemSpacing:0
                                                     headerHeight:0
                                                            items:@[
                                                                    [[IGLayoutTestItem alloc] initWithSize:(CGSize){33,33} expensive:NO],
                                                                    [[IGLayoutTestItem alloc] initWithSize:(CGSize){33,33} expensive:NO],
                                                                    [[IGLayoutTestItem alloc] initWithSize:(CGSize){33,33} expensive:NO],
                                                                    ]],
                            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                                      lineSpacing:0
                                                 interitemSpacing:0
                                                     headerHeight:0
                                                            items:@[
                                                                    [[IGLayoutTestItem alloc] initWithSize:(CGSize){33,33} expensive:NO],
                                                                    ]],
                            ]];
    XCTAssertEqual(self.collectionView.contentSize.height, 66);
    IGAssertEqualFrame([self cellForSection:0 item:0].frame, 0, 0, 33, 33);
    IGAssertEqualFrame([self cellForSection:0 item:1].frame, 33, 0, 33, 33);
    IGAssertEqualFrame([self cellForSection:0 item:2].frame, 66, 0, 33, 33);
    IGAssertEqualFrame([self cellForSection:1 item:0].frame, 0, 33, 33, 33);
}

- (void)test_whenItemsSmallerThanContainerWidth_withHalfPointItemSpacing_with0Insets_with0LineSpacing_thatItemsFitSameRow {
    [self setUpWithStickyHeaders:NO topInset:0];

    [self prepareWithData:@[
                            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                                      lineSpacing:0
                                                 interitemSpacing:0.5
                                                     headerHeight:0
                                                            items:@[
                                                                    [[IGLayoutTestItem alloc] initWithSize:(CGSize){33,33} expensive:NO],
                                                                    [[IGLayoutTestItem alloc] initWithSize:(CGSize){33,33} expensive:NO],
                                                                    [[IGLayoutTestItem alloc] initWithSize:(CGSize){33,33} expensive:NO],
                                                                    ]],
                            ]];
    XCTAssertEqual(self.collectionView.contentSize.height, 33);
    IGAssertEqualFrame([self cellForSection:0 item:0].frame, 0, 0, 33, 33);
    IGAssertEqualFrame([self cellForSection:0 item:1].frame, 33.5, 0, 33, 33);
    IGAssertEqualFrame([self cellForSection:0 item:2].frame, 67, 0, 33, 33);
}

- (void)test_whenSectionsSmallerThanContainerWidth_with0ItemSpacing_with0Insets_with0LineSpacing_thatSectionsFitSameRow {
    [self setUpWithStickyHeaders:NO topInset:0];

    [self prepareWithData:@[
                            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                                      lineSpacing:0
                                                 interitemSpacing:0
                                                     headerHeight:0
                                                            items:@[
                                                                    [[IGLayoutTestItem alloc] initWithSize:(CGSize){33,33} expensive:NO],
                                                                    ]],
                            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                                      lineSpacing:0
                                                 interitemSpacing:0
                                                     headerHeight:0
                                                            items:@[
                                                                    [[IGLayoutTestItem alloc] initWithSize:(CGSize){33,33} expensive:NO],
                                                                    ]],
                            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                                      lineSpacing:0
                                                 interitemSpacing:0
                                                     headerHeight:0
                                                            items:@[
                                                                    [[IGLayoutTestItem alloc] initWithSize:(CGSize){33,33} expensive:NO],
                                                                    ]],
                            ]];
    XCTAssertEqual(self.collectionView.contentSize.height, 33);
    IGAssertEqualFrame([self cellForSection:0 item:0].frame, 0, 0, 33, 33);
    IGAssertEqualFrame([self cellForSection:1 item:0].frame, 33, 0, 33, 33);
    IGAssertEqualFrame([self cellForSection:2 item:0].frame, 66, 0, 33, 33);
}

- (void)test_whenSectionsSmallerThanContainerWidth_withHalfPointSpacing_with0Insets_with0LineSpacing_thatSEctoinsFitSameRow {
    [self setUpWithStickyHeaders:NO topInset:0];

    [self prepareWithData:@[
                            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                                      lineSpacing:0
                                                 interitemSpacing:0.5
                                                     headerHeight:0
                                                            items:@[
                                                                    [[IGLayoutTestItem alloc] initWithSize:(CGSize){33,33} expensive:NO],
                                                                    ]],
                            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                                      lineSpacing:0
                                                 interitemSpacing:0.5
                                                     headerHeight:0
                                                            items:@[
                                                                    [[IGLayoutTestItem alloc] initWithSize:(CGSize){33,33} expensive:NO],
                                                                    ]],
                            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                                      lineSpacing:0
                                                 interitemSpacing:0.5
                                                     headerHeight:0
                                                            items:@[
                                                                    [[IGLayoutTestItem alloc] initWithSize:(CGSize){33,33} expensive:NO],
                                                                    ]],
                            ]];
    XCTAssertEqual(self.collectionView.contentSize.height, 33);
    IGAssertEqualFrame([self cellForSection:0 item:0].frame, 0, 0, 33, 33);
    IGAssertEqualFrame([self cellForSection:1 item:0].frame, 33.5, 0, 33, 33);
    IGAssertEqualFrame([self cellForSection:2 item:0].frame, 67, 0, 33, 33);
}

- (void)test_whenSectionsSmallerThanContainerWidth_with0ItemSpacing_withMiddleItemHasInsets_with0LineSpacing_thatNextSectionSnapsBelow {
    [self setUpWithStickyHeaders:NO topInset:0];

    [self prepareWithData:@[
                            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                                      lineSpacing:0
                                                 interitemSpacing:0
                                                     headerHeight:0
                                                            items:@[
                                                                    [[IGLayoutTestItem alloc] initWithSize:(CGSize){33,33} expensive:NO],
                                                                    ]],
                            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsMake(10, 10, 10, 10)
                                                      lineSpacing:0
                                                 interitemSpacing:0
                                                     headerHeight:0
                                                            items:@[
                                                                    [[IGLayoutTestItem alloc] initWithSize:(CGSize){13,50} expensive:NO],
                                                                    ]],
                            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                                      lineSpacing:0
                                                 interitemSpacing:0
                                                     headerHeight:0
                                                            items:@[
                                                                    [[IGLayoutTestItem alloc] initWithSize:(CGSize){33,33} expensive:NO],
                                                                    ]],
                            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                                      lineSpacing:0
                                                 interitemSpacing:0
                                                     headerHeight:0
                                                            items:@[
                                                                    [[IGLayoutTestItem alloc] initWithSize:(CGSize){33,33} expensive:NO],
                                                                    ]],
                            ]];
    XCTAssertEqual(self.collectionView.contentSize.height, 103);
    IGAssertEqualFrame([self cellForSection:0 item:0].frame, 0, 0, 33, 33);
    IGAssertEqualFrame([self cellForSection:1 item:0].frame, 43, 10, 13, 50);
    IGAssertEqualFrame([self cellForSection:2 item:0].frame, 66, 0, 33, 33);
    IGAssertEqualFrame([self cellForSection:3 item:0].frame, 0, 70, 33, 33);
}

- (void)test_whenSectionBustingRow_thatNewlineAppliesSectionInset {
    [self setUpWithStickyHeaders:NO topInset:0];

    [self prepareWithData:@[
                            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                                      lineSpacing:0
                                                 interitemSpacing:0
                                                     headerHeight:0
                                                            items:@[
                                                                    [[IGLayoutTestItem alloc] initWithSize:(CGSize){33,33} expensive:NO],
                                                                    ]],
                            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsMake(10, 10, 5, 5)
                                                      lineSpacing:0
                                                 interitemSpacing:0
                                                     headerHeight:0
                                                            items:@[
                                                                    [[IGLayoutTestItem alloc] initWithSize:(CGSize){85,50} expensive:NO],
                                                                    ]],
                            ]];
    XCTAssertEqual(self.collectionView.contentSize.height, 98);
    IGAssertEqualFrame([self cellForSection:0 item:0].frame, 0, 0, 33, 33);
    IGAssertEqualFrame([self cellForSection:1 item:0].frame, 10, 43, 85, 50);
}

- (void)test_whenSectionsSmallerThanWidth_withSectionHeader_thatHeaderCausesNewline {
    [self setUpWithStickyHeaders:NO topInset:0];

    [self prepareWithData:@[
                            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                                      lineSpacing:0
                                                 interitemSpacing:0
                                                     headerHeight:0
                                                            items:@[
                                                                    [[IGLayoutTestItem alloc] initWithSize:(CGSize){33,33} expensive:NO],
                                                                    ]],
                            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                                      lineSpacing:0
                                                 interitemSpacing:0
                                                     headerHeight:10
                                                            items:@[
                                                                    [[IGLayoutTestItem alloc] initWithSize:(CGSize){33,33} expensive:NO],
                                                                    ]],
                            ]];
    XCTAssertEqual(self.collectionView.contentSize.height, 76);
    IGAssertEqualFrame([self cellForSection:0 item:0].frame, 0, 0, 33, 33);
    IGAssertEqualFrame([self cellForSection:1 item:0].frame, 0, 43, 33, 33);
}

// TODO(#13785337) bug on osmeta causing 10 more points for collection view content
#if defined(__OSMETA__)
- (void)DISABLED_test_contentSize_andCellFrame_afterBatchUpdates {
#else
    - (void)test_contentSize_andCellFrame_afterBatchUpdates {
#endif
        [self setUpWithStickyHeaders:NO topInset:0];

        const CGFloat headerHeight = 10;
        const CGFloat lineSpacing = 10;
        const UIEdgeInsets insets = UIEdgeInsetsMake(10, 10, 5, 5);

        // making the view bigger so that we can check all cell frames
        self.collectionView.frame = CGRectMake(0, 0, 100, 400);

        [self prepareWithData:@[
                                [[IGLayoutTestSection alloc] initWithInsets:insets
                                                          lineSpacing:lineSpacing
                                                     interitemSpacing:0
                                                         headerHeight:headerHeight
                                                                items:@[
                                                                        [[IGLayoutTestItem alloc] initWithSize:(CGSize){85,10} expensive:NO],
                                                                        [[IGLayoutTestItem alloc] initWithSize:(CGSize){85,20} expensive:NO],
                                                                        ]],
                                [[IGLayoutTestSection alloc] initWithInsets:insets
                                                          lineSpacing:lineSpacing
                                                     interitemSpacing:0
                                                         headerHeight:headerHeight
                                                                items:@[
                                                                        [[IGLayoutTestItem alloc] initWithSize:(CGSize){85,30} expensive:NO],
                                                                        ]],
                                [[IGLayoutTestSection alloc] initWithInsets:insets
                                                          lineSpacing:lineSpacing
                                                     interitemSpacing:0
                                                         headerHeight:headerHeight
                                                                items:@[
                                                                        [[IGLayoutTestItem alloc] initWithSize:(CGSize){85,60} expensive:NO],
                                                                        ]],
                                [[IGLayoutTestSection alloc] initWithInsets:insets
                                                          lineSpacing:lineSpacing
                                                     interitemSpacing:0
                                                         headerHeight:headerHeight
                                                                items:@[
                                                                        [[IGLayoutTestItem alloc] initWithSize:(CGSize){85,40} expensive:NO],
                                                                        ]],
                                ]];

        XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];

        [self.collectionView performBatchUpdates:^{
            self.dataSource.sections = @[
                                         [[IGLayoutTestSection alloc] initWithInsets:insets
                                                                   lineSpacing:lineSpacing
                                                              interitemSpacing:0
                                                                  headerHeight:headerHeight
                                                                         items:@[
                                                                                 [[IGLayoutTestItem alloc] initWithSize:(CGSize){85,30} expensive:NO], // reloaded
                                                                                 // deleted
                                                                                 ]],
                                         // moved from section 3 to 1
                                         [[IGLayoutTestSection alloc] initWithInsets:insets
                                                                   lineSpacing:lineSpacing
                                                              interitemSpacing:0
                                                                  headerHeight:headerHeight
                                                                         items:@[
                                                                                 [[IGLayoutTestItem alloc] initWithSize:(CGSize){85,40} expensive:NO],
                                                                                 ]],
                                         // deleted section 2
                                         [[IGLayoutTestSection alloc] initWithInsets:insets
                                                                   lineSpacing:lineSpacing
                                                              interitemSpacing:0
                                                                  headerHeight:headerHeight
                                                                         items:@[
                                                                                 [[IGLayoutTestItem alloc] initWithSize:(CGSize){85,30} expensive:NO],
                                                                                 [[IGLayoutTestItem alloc] initWithSize:(CGSize){85,10} expensive:NO], // inserted
                                                                                 ]],
                                         // inserted
                                         [[IGLayoutTestSection alloc] initWithInsets:insets
                                                                   lineSpacing:lineSpacing
                                                              interitemSpacing:0
                                                                  headerHeight:headerHeight
                                                                         items:@[
                                                                                 [[IGLayoutTestItem alloc] initWithSize:(CGSize){85,10} expensive:NO],
                                                                                 [[IGLayoutTestItem alloc] initWithSize:(CGSize){85,20} expensive:NO],
                                                                                 ]],
                                         ];

            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:2]];
            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:3]];
            [self.collectionView moveSection:3 toSection:1];
            [self.collectionView reloadItemsAtIndexPaths:@[quickPath(0, 0)]];
            [self.collectionView deleteItemsAtIndexPaths:@[quickPath(0, 1)]];
            [self.collectionView insertItemsAtIndexPaths:@[quickPath(2, 1)]];
        } completion:^(BOOL finished) {
            [self.collectionView layoutIfNeeded];
            [expectation fulfill];

            XCTAssertEqual(self.collectionView.contentSize.height, 260);

            IGAssertEqualFrame([self headerForSection:0].frame, 10, 10, 85, 10);
            IGAssertEqualFrame([self cellForSection:0 item:0].frame, 10, 20, 85, 30);

            IGAssertEqualFrame([self headerForSection:1].frame, 10, 65, 85, 10);
            IGAssertEqualFrame([self cellForSection:1 item:0].frame, 10, 75, 85, 40);

            IGAssertEqualFrame([self headerForSection:2].frame, 10, 130, 85, 10);
            IGAssertEqualFrame([self cellForSection:2 item:0].frame, 10, 140, 85, 30);
            IGAssertEqualFrame([self cellForSection:2 item:1].frame, 10, 180, 85, 10);

            IGAssertEqualFrame([self headerForSection:3].frame, 10, 205, 85, 10);
            IGAssertEqualFrame([self cellForSection:3 item:0].frame, 10, 215, 85, 10);
            IGAssertEqualFrame([self cellForSection:3 item:1].frame, 10, 235, 85, 20);
        }];
        
        [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
            XCTAssertNil(error);
        }];
    }
    
    @end
