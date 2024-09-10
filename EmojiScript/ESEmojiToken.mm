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
#include <numeric>

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

@interface ESEmojiToken () {
    std::vector<UChar32> _unicodes;
}
@end

@implementation ESEmojiToken
@synthesize unicodes = _unicodes;

+ (NSArray<ESEmojiToken *> *)emojiTokensFromURL:(NSURL *)URL {
    ESTextLineEnumerator *enumerator = [[ESTextLineEnumerator alloc] initWithURL:URL];
    
    NSMutableArray<ESEmojiToken *> *emojiTokens = [NSMutableArray new];
    
    for (NSString *textLine in enumerator) {
        NSArray<ESEmojiToken *> *_emojiTokens = [ESEmojiToken _emojiTokensFromTextLine:textLine];
        [emojiTokens addObjectsFromArray:_emojiTokens];
    }
    
    [enumerator release];
    
    return [emojiTokens autorelease];
}

+ (NSArray<ESEmojiToken *> *)_emojiTokensFromTextLine:(NSString *)textLine {
    if ([[textLine stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet] hasPrefix:@"#"]) return nil;
    
    NSArray<NSString *> *components = [textLine componentsSeparatedByString:@";"];
    if (components.count < 2) return nil;
    
    //
    
    NSString *unicharsRangeString = components[0];
    std::vector<std::vector<UChar32>> unicodes;
    NSArray<NSString *> *strings = [ESEmojiToken _stringsFromTextString:unicharsRangeString unicodesOut:&unicodes];
    
    //
    
    NSString *emojiTypeString = [components[1] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    ESEmojiTokenType emojiType = ESEmojiTokenTypeFromNSString(emojiTypeString);
    
    //
    
    NSMutableArray<ESEmojiToken *> *results = [[NSMutableArray alloc] initWithCapacity:strings.count];
    [strings enumerateObjectsUsingBlock:^(NSString * _Nonnull string, NSUInteger idx, BOOL * _Nonnull stop) {
        ESEmojiToken *emojiToken = [[ESEmojiToken alloc] initWithUnicodes:unicodes[idx] emojiType:emojiType string:string];
        [results addObject:emojiToken];
        [emojiToken release];
    }];
    
    return [results autorelease];
}

+ (NSArray<NSString *> *)_stringsFromTextString:(NSString *)string unicodesOut:(std::vector<std::vector<UChar32>> *)unicodesOut {
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
        
        std::vector<std::vector<UChar32>> unicodes {};
        unicodes.reserve(endCode - startCode + 1);
        
        auto stringsVec = std::ranges::iota_view(startCode, endCode + 1)
        | std::views::transform([&unicodes](UChar32 unicode) {
            unicodes.push_back({unicode});
            return [ESEmojiToken _stringFromUnicodes:{unicode}];
        }) | std::ranges::to<std::vector<NSString *>>();
        
        if (unicodesOut != nullptr) {
            *unicodesOut = unicodes;
        }
        
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
            *unicodesOut = {unicodes};
        }
        
        return @[[ESEmojiToken _stringFromUnicodes:unicodes]];
    } else {
        // 2728 또는 1F7F0
        NSScanner *scanner = [NSScanner scannerWithString:trimmed];
        UChar32 unicode;
        assert([scanner scanHexInt:reinterpret_cast<unsigned *>(&unicode)]);
        
        if (unicodesOut != nullptr) {
            *unicodesOut = {{unicode}};
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
    
    [emojiTokens enumerateObjectsUsingBlock:^(ESEmojiToken * _Nonnull emojiToken, NSUInteger emojiTokenIdx, BOOL * _Nonnull stop) {
        switch (emojiToken.emojiType) {
            case ESEmojiTokenBasic: {
                /*
                 261D FE0F (Base)
                 261D 1F3FB
                 261D 1F3FC
                 */
                auto filteredUnicode = emojiToken.unicodes | std::views::filter([](UChar32 &unicode) { return unicode != 0xFE0F; }) | std::ranges::to<std::vector<UChar32>>();
                
                if (filteredUnicode.size() == 1) {
                    NSMutableArray<ESEmojiToken *> *references = [NSMutableArray new];
                    
                    UChar32 baseUnicode = emojiToken.unicodes[0];
                    
                    [emojiTokens enumerateObjectsUsingBlock:^(ESEmojiToken * _Nonnull otherEmojiToken, NSUInteger otherEmojiTokenIdx, BOOL * _Nonnull stop) {
                        if (emojiTokenIdx == otherEmojiTokenIdx) return;
                        if (otherEmojiToken.emojiType != ESEmojiTokenModifierSequence) return;
                        
                        if (otherEmojiToken.unicodes[0] == baseUnicode) {
                            [references addObject:otherEmojiToken];
                        }
                    }];
                    
                    result[emojiToken] = references;
                    [references release];
                } else {
                    result[emojiToken] = @[];
                }
                break;
            }
            case ESEmojiTokenKeycapSequence:
            case ESEmojiTokenTagSequence:
            case ESEmojiTokenFlagSequence: {
                result[emojiToken] = @[];
                break;
            }
            case ESEmojiTokenZMJSequence: {
                NSMutableArray<ESEmojiToken *> *references = [NSMutableArray new];
                
                //
                
                auto unicodesByZWJ = emojiToken.unicodes
                /*
                 1F3CB FE0F 200D 2640 FE0F (Base)
                 1F3CB 1F3FD 200D 2640 FE0F
                 1F3CB 1F3FE 200D 2640 FE0F
                 */
                | std::views::filter([](UChar32 unicode) { return unicode != 0xFE0F; })
                | std::views::split(0x200D)
                | std::views::transform([](auto &&subrange) {
                    return std::vector<int>(subrange.begin(), subrange.end());
                })
                | std::ranges::to<std::vector<std::vector<UChar32>>>();
                
                //
                
                [emojiTokens enumerateObjectsUsingBlock:^(ESEmojiToken * _Nonnull otherEmojiToken, NSUInteger otherEmojiTokenIdx, BOOL * _Nonnull stop) {
                    if (emojiTokenIdx == otherEmojiTokenIdx) return;
                    if (otherEmojiToken.emojiType != ESEmojiTokenZMJSequence) return;
                    
                    //
                    
                    auto otherUnicodesByZWJ = otherEmojiToken.unicodes
                    | std::views::filter([](UChar32 unicode) { return unicode != 0xFE0F; })
                    | std::views::split(0x200D)
                    | std::views::transform([](auto &&subrange) {
                        return std::vector<int>(subrange.begin(), subrange.end());
                    })
                    | std::ranges::to<std::vector<std::vector<UChar32>>>();
                    
                    //
                    
                    /*
                     1F9D8 200D 2640 FE0F (Base)
                     1F9D8 1F3FD 200D 2640 FE0F
                     1F9D8 1F3FB 200D 2640 FE0F
                     마지막 둘끼리 비교할 때는 무시해야함
                     */
                    if (
                        std::accumulate(otherUnicodesByZWJ.cbegin(), otherUnicodesByZWJ.cend(), 0, [](size_t sum, const std::vector<UChar32>& v) {
                            return sum + v.size();
                        })
                        <=
                        std::accumulate(unicodesByZWJ.cbegin(), unicodesByZWJ.cend(), 0, [](size_t sum, const std::vector<UChar32>& v) {
                            return sum + v.size();
                        })
                        )
                    {
                        return;
                    }
                    
                    //
                    
                    if (unicodesByZWJ.size() != otherUnicodesByZWJ.size()) return;
                    
                    for (size_t idx = 0; idx < unicodesByZWJ.size(); idx++) {
                        std::vector<UChar32> unicodes = unicodesByZWJ[idx];
                        std::vector<UChar32> otherUnicodes = otherUnicodesByZWJ[idx];
                        
                        if (otherUnicodes.size() < unicodes.size()) return;
                        if (unicodes[0] != otherUnicodes[0]) return;
                    }
                    
                    [references addObject:otherEmojiToken];
                }];
                
                if (references.count == 0) {
                    [references release];
                    return;
                }
                
                result[emojiToken] = references;
                [references release];
                break;
            }
            default:
                assert(emojiToken.emojiType == ESEmojiTokenModifierSequence);
                assert(emojiToken.unicodes.size() > 1);
                break;
        }
    }];
    
    /*
     1FAF1 1F3FD 200D 1FAF2 1F3FB
     */
    
    return [result autorelease];
}

- (instancetype)initWithUnicodes:(std::vector<UChar32>)unicodes emojiType:(ESEmojiTokenType)emojiType string:(NSString *)string {
    if (self = [super init]) {
        _unicodes = unicodes;
        _emojiType = emojiType;
        _string = [string copy];
    }
    
    return self;
}

- (void)dealloc {
    [_string release];
    [super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@(string: %@)", [super description], _string];
}

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    } else {
        auto casted = static_cast<ESEmojiToken *>(other);
        return /*_unicodes == casted->_unicodes &&*/ _emojiType == casted->_emojiType && [_string isEqualToString:casted->_string];
    }
}

- (NSUInteger)hash {
    NSUInteger hash = 0;
    
    hash ^= _emojiType;

    NSData *data = [_string dataUsingEncoding:NSUTF32StringEncoding];
    const uint32_t *unicodeScalars = (const uint32_t *)data.bytes;
    NSUInteger length = data.length / sizeof(uint32_t);

    for (NSUInteger i = 0; i < length; i++) {
        uint32_t codepoint = unicodeScalars[i];
        hash = hash * 31 + codepoint;
    }

    return hash;
}

- (id)copyWithZone:(struct _NSZone *)zone {
    id copy = [[[self class] allocWithZone:zone] init];
    
    if (copy) {
        auto casted = static_cast<__kindof ESEmojiToken *>(copy);
        casted->_unicodes = _unicodes;
        casted->_string = [_string copy];
        casted->_emojiType = _emojiType;
    }
    
    return copy;
}

@end
