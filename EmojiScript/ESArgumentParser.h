//
//  ESArgumentParser.h
//  EmojiScript
//
//  Created by Jinwoo Kim on 9/7/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

__attribute__((objc_direct_members))
@interface ESArgumentParser : NSObject
@property (class, nonatomic, readonly, nullable) NSURL *emojiSequencesURL;
@property (class, nonatomic, readonly, nullable) NSURL *emojiZWJSequencesURL;
@property (class, nonatomic, readonly, nullable) NSURL *outputStoreURL;
@property (class, nonatomic, readonly) NSString *helpMessage;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
