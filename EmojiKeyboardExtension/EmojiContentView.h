//
//  EmojiContentView.h
//  EmojiKeyboardExtension
//
//  Created by Jinwoo Kim on 9/11/24.
//

#import <UIKit/UIKit.h>
#import "EmojiContentConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

__attribute__((objc_direct_members))
@interface EmojiContentView : UIView <UIContentView>
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame contentConfiguration:(EmojiContentConfiguration *)contentConfiguration;
@end

NS_ASSUME_NONNULL_END
