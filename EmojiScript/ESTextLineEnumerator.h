//
//  ESTextLineEnumerator.h
//  EmojiScript
//
//  Created by Jinwoo Kim on 9/7/24.
//

#import <Foundation/Foundation.h>

#ifndef USE_STACK_POINTER
#define USE_STACK_POINTER 1
#endif

NS_ASSUME_NONNULL_BEGIN

#if USE_STACK_POINTER
NS_SWIFT_UNAVAILABLE_FROM_ASYNC("Unavaiable when USE_STACK_POINTER.")
#endif
@interface ESTextLineEnumerator : NSObject <NSFastEnumeration> /*NSEnumerator*/
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithURL:(NSURL *)URL;
@end

NS_ASSUME_NONNULL_END
