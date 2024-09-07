//
//  ESEmojiTokenEnumerator.h
//  EmojiScript
//
//  Created by Jinwoo Kim on 9/7/24.
//

#import <Foundation/Foundation.h>
#import "ESEmojiToken.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESEmojiTokenEnumerator : NSEnumerator
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithURL:(NSURL *)URL;
@end

NS_ASSUME_NONNULL_END
