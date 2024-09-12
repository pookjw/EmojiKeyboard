//
//  EmojisViewModel.h
//  EmojiKeyboardExtension
//
//  Created by Jinwoo Kim on 9/11/24.
//

#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

__attribute__((objc_direct_members))
@interface EmojisViewModel : NSObject
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDataSource:(UICollectionViewDiffableDataSource<NSString *, NSManagedObjectID *> *)dataSource;
- (void)loadDataSourceWithCompletionHandler:(void (^)(NSError * _Nullable error))completionHandler;
- (void)managedObjectAtIndexPath:(NSIndexPath *)indexPath completionHandler:(void (^)(NSManagedObject * _Nullable managedObject))completionHandler;
- (void)emojiInfoAtIndexPath:(NSIndexPath *)indexPath completionHandler:(void (^)(NSString * _Nullable emojiString, NSString * _Nullable emojiIdentifier, NSArray<NSString *> * _Nullable childEmojiStrings, NSArray<NSString *> * _Nullable childEmojiIdentifiers))completionHandler;
@end

NS_ASSUME_NONNULL_END
