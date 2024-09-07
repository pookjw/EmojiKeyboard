//
//  ESEmojiTextFileEnumerator.mm
//  EmojiScript
//
//  Created by Jinwoo Kim on 9/7/24.
//

#import "ESEmojiTextFileEnumerator.h"

@interface ESEmojiTextFileEnumerator () <NSStreamDelegate> {
    NSInputStream *_inputStream;
}
@end

@implementation ESEmojiTextFileEnumerator

- (instancetype)initWithURL:(NSURL *)URL {
    if (self = [super init]) {
        _inputStream = [[NSInputStream alloc] initWithURL:URL];
    }
    
    return self;
}

- (void)dealloc {
    [_inputStream release];
    [super dealloc];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id _Nullable[])buffer count:(NSUInteger)len {
    if (state->state == 0) {
        [_inputStream open];
        state->itemsPtr = buffer;
        state->state = 1;
    }
    
    uint8_t bytes[256];
    NSUInteger readSize = [_inputStream read:bytes maxLength:256];
    NSString *string = [NSString stringWithCString:reinterpret_cast<const char *>(bytes) encoding:NSUTF8StringEncoding];
    [_inputStream read:bytes maxLength:256];
    NSString *string_2 = [NSString stringWithCString:reinterpret_cast<const char *>(bytes) encoding:NSUTF8StringEncoding];
    
    return 0;
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    
}

@end
