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
        
        NSLog(@"%@", [ESEmojiToken emojiTokensFromURL:emojiSequencesURL]);
        
        return EXIT_SUCCESS;
    }
}
