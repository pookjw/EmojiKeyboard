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
- (NSManagedObject *)managedObjectAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)main_emojiStringAtIndexPath:(NSIndexPath *)indexPath identifierOut:(NSString * _Nonnull __autoreleasing * _Nullable)identifierOut;
- (NSArray<NSString *> *)main_childEmojiStringsAtIndexPath:(NSIndexPath *)indexPath identifiersOut:(NSArray<NSString *> * _Nonnull __autoreleasing * _Nullable)identifiersOut;
@end

NS_ASSUME_NONNULL_END
