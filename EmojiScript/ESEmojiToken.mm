//
//  ESEmojiToken.mm
//  EmojiScript
//
//  Created by Jinwoo Kim on 9/7/24.
//

#import "ESEmojiToken+Private.h"
#include <utility>

namespace std {
    template<typename T>
    struct hash<vector<T>> {
        std::size_t operator()(vector<T> const &vec) const {
            std::hash<T> hasher;
            size_t size = vec.size();
            size_t result = 0;
            
            for (size_t i = 0; i < size; i++) {
                result ^= hasher(vec.at(i));
            }
            
            return result;
        }
    };
}

@implementation ESEmojiToken

- (instancetype)initWithUnichars:(std::vector<UChar>)unichars emojiType:(ESEmojiTokenType)emojiType {
    if (self = [super init]) {
        _unichars = unichars;
        _emojiType = emojiType;
    }
    
    return self;
}

- (instancetype)initWithString:(NSString *)string {
    abort();
}

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    } else {
        auto casted = static_cast<ESEmojiToken *>(other);
        return _unichars == casted->_unichars && _emojiType == casted->_emojiType;
    }
}

- (NSUInteger)hash {
    size_t unicharsHash = std::hash<std::vector<UChar>>()(_unichars);
    return static_cast<NSUInteger>(unicharsHash) ^ _emojiType;
}

- (NSString *)string {
    abort();
}

@end
