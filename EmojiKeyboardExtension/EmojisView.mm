//
//  EmojisView.m
//  EmojiKeyboardExtension
//
//  Created by Jinwoo Kim on 9/11/24.
//

#import "EmojisView.h"
#import "EmojisViewModel.h"
#import "EmojiContentConfiguration.h"
#import <objc/message.h>
#import <objc/runtime.h>

@interface EmojisView () <UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (retain, nonatomic, readonly) UICollectionView *collectionView;
@property (retain, nonatomic, readonly) UICollectionViewCellRegistration *cellRegistration;
@property (retain, nonatomic, readonly) EmojisViewModel *viewModel;
@end

@implementation EmojisView
@synthesize collectionView = _collectionView;
@synthesize viewModel = _viewModel;
@synthesize cellRegistration = _cellRegistration;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UICollectionView *collectionView = self.collectionView;
        collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:collectionView];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTriggerTapGestureRecognizer:)];
        [collectionView addGestureRecognizer:tapGestureRecognizer];
        [tapGestureRecognizer release];
        
        [self.viewModel loadDataSourceWithCompletionHandler:^(NSError * _Nullable error) {
            assert(error == nil);
        }];
    }
    
    return self;
}

- (void)dealloc {
    [_collectionView release];
    [_viewModel release];
    [_cellRegistration release];
    [super dealloc];
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(size.width, 400.);
}

- (void)didTriggerTapGestureRecognizer:(UITapGestureRecognizer *)sender {
    UICollectionView *collectionView = self.collectionView;
    
    for (UIContextMenuInteraction *contextMenuInteraction in collectionView.interactions) {
        if (![contextMenuInteraction isKindOfClass:UIContextMenuInteraction.class]) continue;
        
        CGPoint location = [sender locationInView:collectionView];
        reinterpret_cast<void (*)(id, SEL, CGPoint)>(objc_msgSend)(contextMenuInteraction, sel_registerName("_presentMenuAtLocation:"), location);
        break;
    }
}

- (UICollectionView *)collectionView {
    if (auto collectionView = _collectionView) return collectionView;
    
    UICollectionViewFlowLayout *collectionViewLayout = [UICollectionViewFlowLayout new];
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:collectionViewLayout];
    [collectionViewLayout release];
    
    collectionView.backgroundColor = UIColor.clearColor;
    collectionView.delegate = self;
    
    _collectionView = [collectionView retain];
    return [collectionView autorelease];
}

- (EmojisViewModel *)viewModel {
    if (auto viewModel = _viewModel) return viewModel;
    
    UICollectionViewDiffableDataSource<NSString *, NSManagedObjectID *> *dataSource = [self newDataSource];
    EmojisViewModel *viewModel = [[EmojisViewModel alloc] initWithDataSource:dataSource];
    [dataSource release];
    
    _viewModel = [viewModel retain];
    return [viewModel autorelease];
}

- (UICollectionViewCellRegistration *)cellRegistration {
    if (auto cellRegistration = _cellRegistration) return cellRegistration;
    
    __weak auto weakSelf = self;
    
    UICollectionViewCellRegistration *cellRegistration = [UICollectionViewCellRegistration registrationWithCellClass:UICollectionViewCell.class configurationHandler:^(__kindof UICollectionViewCell * _Nonnull cell, NSIndexPath * _Nonnull indexPath, NSManagedObjectID * _Nonnull managedObjectID) {
        NSManagedObject * _Nullable managedObject = [weakSelf.viewModel managedObjectAtIndexPath:indexPath];
        EmojiContentConfiguration *contentConfiguration = [[EmojiContentConfiguration alloc] initWithEmoji:managedObject initialFrame:cell.bounds];
        cell.contentConfiguration = contentConfiguration;
        [contentConfiguration release];
    }];
    
    _cellRegistration = [cellRegistration retain];
    return cellRegistration;
}

- (UICollectionViewDiffableDataSource<NSString *, NSManagedObjectID *> *)newDataSource {
    UICollectionViewCellRegistration *cellRegistration = self.cellRegistration;
    
    UICollectionViewDiffableDataSource<NSString *, NSManagedObjectID *> *dataSource = [[UICollectionViewDiffableDataSource alloc] initWithCollectionView:self.collectionView cellProvider:^UICollectionViewCell * _Nullable(UICollectionView * _Nonnull collectionView, NSIndexPath * _Nonnull indexPath, NSManagedObjectID * _Nonnull itemIdentifier) {
        UICollectionViewCell *cell = [collectionView dequeueConfiguredReusableCellWithRegistration:cellRegistration forIndexPath:indexPath item:itemIdentifier];
        return cell;
    }];
    
    return dataSource;
}

- (UIContextMenuConfiguration *)collectionView:(UICollectionView *)collectionView contextMenuConfigurationForItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths point:(CGPoint)point {
    NSIndexPath * _Nullable indexPath = indexPaths.firstObject;
    if (indexPath == nil) return nil;
    
    NSArray<NSString *> *childIdentifiers;
    NSArray<NSString *> *childEmojiStrings = [self.viewModel main_childEmojiStringsAtIndexPath:indexPath identifiersOut:&childIdentifiers];
    
    UIContextMenuConfiguration *contextMenuConfiguration = [UIContextMenuConfiguration configurationWithIdentifier:nil
                                                                                                   previewProvider:^UIViewController * _Nullable{
        return nil;
    }
                                                                                                    actionProvider:^UIMenu * _Nullable(NSArray<UIMenuElement *> * _Nonnull suggestedActions) {
        NSMutableArray<UIMenuElement *> *actions = [[NSMutableArray alloc] initWithCapacity:childEmojiStrings.count];
        
        [childEmojiStrings enumerateObjectsUsingBlock:^(NSString * _Nonnull string, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *identifier = childIdentifiers[idx];
            
            UIAction *action = [UIAction actionWithTitle:string image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
                
            }];
            
            action.subtitle = identifier;
            
            [actions addObject:action];
        }];
        
        UIMenu *menu = [UIMenu menuWithChildren:actions];
        [actions release];
        
        return menu;
    }];
    
    return contextMenuConfiguration;
}

@end
