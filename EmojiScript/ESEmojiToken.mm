//
//  ESEmojiToken.mm
//  EmojiScript
//
//  Created by Jinwoo Kim on 9/7/24.
//

#import "ESEmojiToken.h"
#import "ESTextLineEnumerator.h"
#include <utility>
#include <ranges>

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

+ (NSArray<ESEmojiToken *> *)emojiTokensFromURL:(NSURL *)URL {
    ESTextLineEnumerator *enumerator = [[ESTextLineEnumerator alloc] initWithURL:URL];
    
    NSMutableArray<ESEmojiToken *> *emojiTokens = [NSMutableArray new];
    
    for (NSString *textLine in enumerator) {
        ESEmojiToken * _Nullable emojiToken = [ESEmojiToken emojiTokenFromTextLine:textLine];
        if (emojiToken == nil) continue;
        
        [emojiTokens addObject:emojiToken];
    }
    
    return [emojiTokens autorelease];
}

+ (ESEmojiToken * _Nullable)emojiTokenFromTextLine:(NSString *)textLine {
    if ([[textLine stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet] hasPrefix:@"#"]) return nil;
    
    NSArray<NSString *> *components = [textLine componentsSeparatedByString:@";"];
    if (components.count < 2) return nil;
    
    //
    
    NSString *unicharsRangeString = [components[0] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    std::vector<unichar> unichars;
    
    if (unicharsRangeString.length == 10) {
        NSArray<NSString *> *unicharsRangeComponents = [unicharsRangeString componentsSeparatedByString:@".."];
        if (unicharsRangeComponents.count != 2) return nil;
        
        NSScanner *startScanner = [NSScanner scannerWithString:unicharsRangeComponents[0]];
        unsigned long long startCode;
        if (![startScanner scanHexLongLong:&startCode]) return nil;
        
        NSScanner *endScanner = [NSScanner scannerWithString:unicharsRangeComponents[1]];
        unsigned long long endCode;
        if (![endScanner scanHexLongLong:&endCode]) return nil;
        
        unichars = std::ranges::iota_view {startCode, endCode + 1} | std::ranges::to<std::vector<UChar>>();
    } else if (unicharsRangeString.length == 4) {
        NSScanner *scanner = [NSScanner scannerWithString:unicharsRangeString];
        unsigned long long code;
        if (![scanner scanHexLongLong:&code]) return nil;
        
        unichars = {static_cast<UChar>(code)};
    } else {
        return nil;
    }
    
    //
    
    NSString *emojiTypeString = [components[1] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    
    ESEmojiTokenType emojiType;
    if ([emojiTypeString isEqualToString:@"Basic_Emoji"]) {
        emojiType = ESEmojiTokenBasic;
    } else if ([emojiTypeString isEqualToString:@"Emoji_Keycap_Sequence"]) {
        emojiType = ESEmojiTokenKeycapSequence;
    } else if ([emojiTypeString isEqualToString:@"RGI_Emoji_Flag_Sequence"]) {
        emojiType = ESEmojiTokenFlagSequence;
    } else if ([emojiTypeString isEqualToString:<#(nonnull NSString *)#>])
    abort();
}

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
