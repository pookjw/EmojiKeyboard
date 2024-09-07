//
//  main.mm
//  EmojiScript
//
//  Created by Jinwoo Kim on 9/7/24.
//

#import <CoreData/CoreData.h>
#import "ESArgumentParser.h"
#import "ESTextLineEnumerator.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSURL * _Nullable emojiSequencesURL = [ESArgumentParser emojiSequencesURL];
        NSURL * _Nullable emojiZWJSequencesURL = [ESArgumentParser emojiZWJSequencesURL];
        
        if (emojiSequencesURL == nil || emojiSequencesURL == nil) {
            NSLog(@"%@", ESArgumentParser.helpMessage);
            return EXIT_FAILURE;
        }
        
        ESTextLineEnumerator *enumerator = [[ESTextLineEnumerator alloc] initWithURL:emojiSequencesURL];
        
        for (id foo in enumerator) {
            NSLog(@"%@", foo);
        }
        
        return EXIT_SUCCESS;
    }
}
