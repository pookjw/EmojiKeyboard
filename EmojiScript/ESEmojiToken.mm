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
#include <algorithm>
#include <vector>

NSString * NSStringFromESEmojiTokenType(ESEmojiTokenType emojiType) {
    switch (emojiType) {
        case ESEmojiTokenBasic:
            return @"Basic_Emoji";
        case ESEmojiTokenKeycapSequence:
            return @"Emoji_Keycap_Sequence";
        case ESEmojiTokenFlagSequence:
            return @"RGI_Emoji_Flag_Sequence";
        case ESEmojiTokenTagSequence:
            return @"RGI_Emoji_Tag_Sequence";
        case ESEmojiTokenModifierSequence:
            return @"RGI_Emoji_Modifier_Sequence";
        case ESEmojiTokenZMJSequence:
            return @"RGI_Emoji_ZWJ_Sequence";
        default:
            return nil;
    }
}

ESEmojiTokenType ESEmojiTokenTypeFromNSString(NSString *string) {
    if ([string isEqualToString:@"Basic_Emoji"]) {
        return ESEmojiTokenBasic;
    } else if ([string isEqualToString:@"Emoji_Keycap_Sequence"]) {
        return ESEmojiTokenKeycapSequence;
    } else if ([string isEqualToString:@"RGI_Emoji_Flag_Sequence"]) {
        return ESEmojiTokenFlagSequence;
    } else if ([string isEqualToString:@"RGI_Emoji_Tag_Sequence"]) {
        return ESEmojiTokenTagSequence;
    } else if ([string isEqualToString:@"RGI_Emoji_Modifier_Sequence"]) {
        return ESEmojiTokenModifierSequence;
    } else if ([string isEqualToString:@"RGI_Emoji_ZWJ_Sequence"]) {
        return ESEmojiTokenZMJSequence;
    } else {
        abort();
    }
}

namespace std {
    template<typename T>
    struct hash<vector<T>> {
        std::size_t operator()(vector<T> const &vec) const {
            std::hash<T> hasher;
            size_t size = vec.size();
            size_t result = 0;
            
            for (size_t i = 0; i < size; i++) {
                result ^= (hasher(vec.at(i)) << i);
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
        ESEmojiToken * _Nullable emojiToken = [ESEmojiToken _emojiTokenFromTextLine:textLine];
        if (emojiToken == nil) continue;
        
        [emojiTokens addObject:emojiToken];
    }
    
    [enumerator release];
    
    return [emojiTokens autorelease];
}

+ (ESEmojiToken * _Nullable)_emojiTokenFromTextLine:(NSString *)textLine {
    if ([[textLine stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet] hasPrefix:@"#"]) return nil;
    
    NSArray<NSString *> *components = [textLine componentsSeparatedByString:@";"];
    if (components.count < 2) return nil;
    
    //
    
    NSString *unicharsRangeString = components[0];
    std::vector<UChar32> unicodes;
    NSArray<NSString *> *strings = [ESEmojiToken _stringsFromTextString:unicharsRangeString unicodesOut:&unicodes];
    
    //
    
    NSString *emojiTypeString = [components[1] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    ESEmojiTokenType emojiType = ESEmojiTokenTypeFromNSString(emojiTypeString);
    
    return [[[ESEmojiToken alloc] initWithUnicodes:unicodes emojiType:emojiType strings:strings] autorelease];
}

+ (NSArray<NSString *> *)_stringsFromTextString:(NSString *)string unicodesOut:(std::vector<UChar32> *)unicodesOut {
    assert(string.length > 0);
    assert(sizeof(unsigned) == sizeof(UChar32));
    
    NSString *trimmed = nil;
    for (NSInteger idx = string.length - 1; idx >= 0; idx--) {
        if ([string characterAtIndex:idx] != 0x20) {
            trimmed = [string substringToIndex:idx + 1];
            break;
        }
    }
    
    if (trimmed == nil) trimmed = string;
    
    //
    
    if ([trimmed containsString:@".."]) {
        // 2795..2797 또는 1F232..1F236
        NSArray<NSString *> *components = [trimmed componentsSeparatedByString:@".."];
        assert(components.count == 2);
        
        NSScanner *startCodeScanner = [NSScanner scannerWithString:components[0]];
        UChar32 startCode;
        assert([startCodeScanner scanHexInt:reinterpret_cast<unsigned *>(&startCode)]);
        
        NSScanner *endCodeScanner = [NSScanner scannerWithString:components[1]];
        UChar32 endCode;
        assert([endCodeScanner scanHexInt:reinterpret_cast<unsigned *>(&endCode)]);
        
        auto unicodes = std::ranges::iota_view(startCode, endCode + 1) | std::ranges::to<std::vector<UChar32>>();
        if (unicodesOut != nullptr) {
            *unicodesOut = unicodes;
        }
        
        auto stringsVec = unicodes
        | std::views::transform([](UChar32 unicode) {
            return [ESEmojiToken _stringFromUnicodes:{unicode}];
        }) | std::ranges::to<std::vector<NSString *>>();
        
        return [[[NSArray alloc] initWithObjects:stringsVec.data() count:stringsVec.size()] autorelease];
    } else if ([trimmed containsString:@" "]) {
        // 2696 FE0F 또는 1F321 FE0F
        NSArray<NSString *> *components = [trimmed componentsSeparatedByString:@" "];
        
        std::vector<UChar32> unicodes {};
        unicodes.reserve(components.count);
        for (NSString *component in components) {
            NSScanner *scanner = [NSScanner scannerWithString:component];
            UChar32 unicode;
            assert([scanner scanHexInt:reinterpret_cast<unsigned *>(&unicode)]);
            unicodes.push_back(unicode);
        }
        
        if (unicodesOut != nullptr) {
            *unicodesOut = unicodes;
        }
        
        return @[[ESEmojiToken _stringFromUnicodes:unicodes]];
    } else {
        // 2728 또는 1F7F0
        NSScanner *scanner = [NSScanner scannerWithString:trimmed];
        UChar32 unicode;
        assert([scanner scanHexInt:reinterpret_cast<unsigned *>(&unicode)]);
        
        if (unicodesOut != nullptr) {
            *unicodesOut = {unicode};
        }
        
        return @[[ESEmojiToken _stringFromUnicodes:{unicode}]];
    }
}

+ (NSString *)_stringFromUnicodes:(std::vector<UChar32>)unicodes {
    std::vector<unsigned char> chars {};
    
    //
    
    std::for_each(unicodes.cbegin(), unicodes.cend(), [&chars](UChar32 unicode) {
        // https://github.com/facebook/folly/blob/main/folly/Unicode.cpp
        // https://stackoverflow.com/a/6240184/17473716
        if (unicode < 0x7F) {
            chars.push_back(static_cast<unsigned char>(unicode));
        } else if (unicode <= 0x7FF) {
            chars.reserve(2);
            chars.push_back(static_cast<unsigned char>(0xC0 | (unicode >> 6)));
            chars.push_back(static_cast<unsigned char>(0x80 | (0x3f & unicode)));
        } else if (unicode <= 0xFFFF) {
            chars.reserve(3);
            chars.push_back(static_cast<unsigned char>(0xE0 | (unicode >> 12)));
            chars.push_back(static_cast<unsigned char>(0x80 | (0x3f & (unicode >> 6))));
            chars.push_back(static_cast<unsigned char>(0x80 | (0x3f & unicode)));
        } else if (unicode <= 0x10FFFF) {
            chars.reserve(4);
            chars.push_back(static_cast<unsigned char>(0xF0 | (unicode >> 18)));
            chars.push_back(static_cast<unsigned char>(0x80 | (0x3f & (unicode >> 12))));
            chars.push_back(static_cast<unsigned char>(0x80 | (0x3f & (unicode >> 6))));
            chars.push_back(static_cast<unsigned char>(0x80 | (0x3f & unicode)));
        }
    });
    
    //
    
    return [[[NSString alloc] initWithBytes:chars.data() length:chars.size() encoding:NSUTF8StringEncoding] autorelease];
}

+ (NSDictionary<ESEmojiToken *, NSArray<ESEmojiToken *> *> *)emojiTokenReferencesFromEmojiTokens:(NSArray<ESEmojiToken *> *)emojiTokens {
    NSMutableDictionary<ESEmojiToken *, NSArray<ESEmojiToken *> *> * result = [NSMutableDictionary new];
    
    for (ESEmojiToken *emojiToken in emojiTokens) @autoreleasepool {
        if (emojiToken.unicodes.size() == 0) {
            result[emojiToken] = @[];
            continue;
        }
    }
    
    return [result autorelease];
}

- (instancetype)initWithUnicodes:(std::vector<UChar32>)unicodes emojiType:(ESEmojiTokenType)emojiType strings:(NSArray<NSString *> *)strings {
    if (self = [super init]) {
        _unicodes = unicodes;
        _emojiType = emojiType;
        _strings = [strings copy];
    }
    
    return self;
}

- (void)dealloc {
    [_strings release];
    [super dealloc];
}

- (NSString *)description {
    NSMutableString *strings = [NSMutableString new];
    for (NSString *string in _strings) {
        [strings appendString:string];
    }
    
    NSString *result = [NSString stringWithFormat:@"%@(strings: %@)", [super description], strings];
    [strings release];
    return result;
}

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    } else {
        auto casted = static_cast<ESEmojiToken *>(other);
        return _unicodes == casted->_unicodes && _emojiType == casted->_emojiType;
    }
}

- (NSUInteger)hash {
    __block NSUInteger hash = 0;
    
    hash ^= _emojiType;
    
    [_strings enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        hash ^= (obj.hash << (idx + 1));
    }];
    
    size_t unicodesash = std::hash<std::vector<UChar32>>()(_unicodes);
    hash ^= static_cast<NSUInteger>(unicodesash);
    
    return hash;
}

- (id)copyWithZone:(struct _NSZone *)zone {
    id copy = [[[self class] allocWithZone:zone] init];
    
    if (copy) {
        auto casted = static_cast<__kindof ESEmojiToken *>(copy);
        casted->_unicodes = _unicodes;
        casted->_strings = [_strings copy];
        casted->_emojiType = _emojiType;
    }
    
    return copy;
}

@end
