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

__attribute__((objc_direct_members))
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
    [_keyInput release];
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
        EmojiContentConfiguration *contentConfiguration = [[EmojiContentConfiguration alloc] initWithInitialFrame:cell.bounds emojiHandler:^(void (^ _Nonnull completionHandler)(NSManagedObject * _Nullable)) {
            [weakSelf.viewModel managedObjectAtIndexPath:indexPath completionHandler:^(NSManagedObject * _Nullable managedObject) {
                completionHandler(managedObject);
            }];
        }];
        cell.contentConfiguration = contentConfiguration;
        [contentConfiguration release];
    }];
    
    _cellRegistration = [cellRegistration retain];
    return cellRegistration;
}

- (UICollectionViewDiffableDataSource<NSString *, NSManagedObjectID *> *)newDataSource  __attribute__((objc_direct)) {
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
    
    EmojisViewModel *viewModel = self.viewModel;
    
    __weak auto weakSelf = self;
    
    UIContextMenuConfiguration *contextMenuConfiguration = [UIContextMenuConfiguration configurationWithIdentifier:nil
                                                                                                   previewProvider:^UIViewController * _Nullable{
        return nil;
    }
                                                                                                    actionProvider:^UIMenu * _Nullable(NSArray<UIMenuElement *> * _Nonnull suggestedActions) {
        UIDeferredMenuElement *element = [UIDeferredMenuElement elementWithProvider:^(void (^ _Nonnull completion)(NSArray<UIMenuElement *> * _Nonnull)) {
            [viewModel emojiInfoAtIndexPath:indexPath completionHandler:^(NSString * _Nullable emojiString, NSString * _Nullable emojiIdentifier, NSArray<NSString *> * _Nullable childEmojiStrings, NSArray<NSString *> * _Nullable childEmojiIdentifiers) {
                NSMutableArray<UIMenuElement *> *results = [[NSMutableArray alloc] initWithCapacity:childEmojiStrings.count + 1];
                
                //
                
                UIAction *action = [UIAction actionWithTitle:emojiString image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
                    [weakSelf.keyInput insertText:emojiString];
                }];
                
                action.subtitle = emojiIdentifier;
                [results addObject:action];
                
                //
                
                [childEmojiStrings enumerateObjectsUsingBlock:^(NSString * _Nonnull childEmojiString, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSString *childEmojiIdentifier = childEmojiIdentifiers[idx];
                    
                    UIAction *action = [UIAction actionWithTitle:childEmojiString image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
                        [weakSelf.keyInput insertText:childEmojiString];
                    }];
                    
                    action.subtitle = childEmojiIdentifier;
                    
                    [results addObject:action];
                }];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(results);
                });
                
                [results release];
            }];
        }];
        
        
        UIMenu *menu = [UIMenu menuWithChildren:@[element]];
        
        return menu;
    }];
    
    return contextMenuConfiguration;
}

@end
