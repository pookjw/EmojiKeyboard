//
//  ESEmojiToken.h
//  EmojiScript
//
//  Created by Jinwoo Kim on 9/7/24.
//

#import <Foundation/Foundation.h>
#import <unicode/utf16.h>
#include <vector>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ESEmojiTokenType) {
    ESEmojiTokenBasic,
    ESEmojiTokenKeycapSequence,
    ESEmojiTokenFlagSequence,
    ESEmojiTokenTagSequence,
    ESEmojiTokenModifierSequence,
    ESEmojiTokenZMJSequence
};

extern NSString * NSStringFromESEmojiTokenType(ESEmojiTokenType emojiType);
extern ESEmojiTokenType ESEmojiTokenTypeFromNSString(NSString *string);

@interface ESEmojiToken : NSObject <NSCopying>
@property (assign, nonatomic, readonly) const std::vector<UChar32> unicodes;
@property (assign, nonatomic, readonly) ESEmojiTokenType emojiType;
@property (copy, nonatomic, readonly) NSString *string;
@property (copy, nonatomic, readonly) NSString *identifier;
+ (NSArray<ESEmojiToken *> *)emojiTokensFromURL:(NSURL *)URL;
+ (NSDictionary<ESEmojiToken *, NSArray<ESEmojiToken *> *> *)emojiTokenReferencesFromEmojiTokens:(NSArray<ESEmojiToken *> *)emojiTokens;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
