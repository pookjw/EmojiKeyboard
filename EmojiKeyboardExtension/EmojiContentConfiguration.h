//
//  EmojiContentConfiguration.h
//  EmojiKeyboardExtension
//
//  Created by Jinwoo Kim on 9/11/24.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

__attribute__((objc_direct_members))
@interface EmojiContentConfiguration : NSObject <UIContentConfiguration>
@property (copy, nonatomic, readonly) void (^emojiHandler)(void (^completionHandler)(NSManagedObject * _Nullable emoji));
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithInitialFrame:(CGRect)initialFrame emojiHandler:(void (^)(void (^completionHandler)(NSManagedObject * _Nullable emoji)))emojiHandler;
@end

NS_ASSUME_NONNULL_END
