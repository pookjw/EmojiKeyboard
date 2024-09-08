//
//  ESEmojiToken.h
//  EmojiScript
//
//  Created by Jinwoo Kim on 9/7/24.
//

#import <Foundation/Foundation.h>
#import <unicode/utf8.h>
#include <vector>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ESEmojiTokenType) {
    ESEmojiTokenBasic,
    ESEmojiTokenKeycapSequence,
    ESEmojiTokenFlagSequence,
    ESEmojiTokenModifierSequence,
    ESEmojiTokenZMJSequence
};

@interface ESEmojiToken : NSObject
@property (assign, nonatomic, readonly) std::vector<UChar> unichars;
@property (assign, nonatomic, readonly) ESEmojiTokenType emojiType;
@property (nonatomic, readonly) NSString *string;
+ (NSArray<ESEmojiToken *> *)emojiTokensFromURL:(NSURL *)URL;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
