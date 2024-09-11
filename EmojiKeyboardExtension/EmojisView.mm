//
//  EmojisView.m
//  EmojiKeyboardExtension
//
//  Created by Jinwoo Kim on 9/11/24.
//

#import "EmojisView.h"
#import "EmojisViewModel.h"

@interface EmojisView () <UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (retain, nonatomic, readonly) UICollectionView *collectionView;
@property (retain, nonatomic, readonly) EmojisViewModel *viewModel;
@end

@implementation EmojisView
@synthesize collectionView = _collectionView;
@synthesize viewModel = _viewModel;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.systemOrangeColor;
        
        [self.viewModel loadDataSourceWithCompletionHandler:^(NSError * _Nullable error) {
            assert(error == nil);
        }];
    }
    
    return self;
}

- (void)dealloc {
    [_collectionView release];
    [_viewModel release];
    [super dealloc];
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(size.width, 400.);
}

- (EmojisViewModel *)viewModel {
    if (auto viewModel = _viewModel) return viewModel;
    
    EmojisViewModel *viewModel = [[EmojisViewModel alloc] initWithDataSource:nil];
    
    _viewModel = [viewModel retain];
    return [viewModel autorelease];
}

@end
