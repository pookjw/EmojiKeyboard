//
//  ESTextLineEnumerator.h
//  EmojiScript
//
//  Created by Jinwoo Kim on 9/7/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ESTextLineEnumerator : NSObject <NSFastEnumeration> /*NSEnumerator*/
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithURL:(NSURL *)URL;
@end

NS_ASSUME_NONNULL_END
