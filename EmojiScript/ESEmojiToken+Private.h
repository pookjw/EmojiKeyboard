//
//  ESEmojiToken+Private.h
//  EmojiScript
//
//  Created by Jinwoo Kim on 9/7/24.
//

#import "ESEmojiToken.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESEmojiToken (Private)
- (instancetype)initWithUnichars:(std::vector<UChar>)unichars emojiType:(ESEmojiTokenType)emojiType;
- (instancetype)initWithString:(NSString *)string;
@end

NS_ASSUME_NONNULL_END
