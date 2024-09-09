//
//  main.mm
//  EmojiScript
//
//  Created by Jinwoo Kim on 9/7/24.
//

#import <CoreData/CoreData.h>
#import "ESArgumentParser.h"
#import "ESEmojiToken.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSURL * _Nullable emojiSequencesURL = [ESArgumentParser emojiSequencesURL];
        NSURL * _Nullable emojiZWJSequencesURL = [ESArgumentParser emojiZWJSequencesURL];
        
        if (emojiSequencesURL == nil || emojiSequencesURL == nil) {
            NSLog(@"%@", ESArgumentParser.helpMessage);
            return EXIT_FAILURE;
        }
        
        NSMutableSet<NSNumber *> *hashes = [NSMutableSet new];
        NSUInteger count = 0;
        
        NSArray<ESEmojiToken *> *tokens = [ESEmojiToken emojiTokensFromURL:emojiSequencesURL];
        [tokens enumerateObjectsUsingBlock:^(ESEmojiToken * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx + 1 == tokens.count) {
                *stop = YES;
                return;
            }
            
            [[tokens subarrayWithRange:NSMakeRange(idx + 1, tokens.count - idx - 1)] enumerateObjectsUsingBlock:^(ESEmojiToken * _Nonnull other, NSUInteger idx, BOOL * _Nonnull stop) {
                assert(obj.hash != other.hash);
            }];
        }];
        
        for (ESEmojiToken *token in tokens){
            NSLog(@"%@", token.description);
            [hashes addObject:@(token.hash)];
            count += 1;
        }
        assert(hashes.count == count);
        
        for (ESEmojiToken *token in [ESEmojiToken emojiTokensFromURL:emojiZWJSequencesURL]){
            NSLog(@"%@", token.description);
            [hashes addObject:@(token.hash)];
            count += 1;
        }
        
        assert(hashes.count == count);
        
        return EXIT_SUCCESS;
    }
}
