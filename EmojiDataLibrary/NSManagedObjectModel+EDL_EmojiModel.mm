//
//  NSManagedObjectModel+EDL_EmojiModel.mm
//  EmojiDataLibrary
//
//  Created by Jinwoo Kim on 9/11/24.
//

#import "NSManagedObjectModel+EDL_EmojiModel.h"

@implementation NSManagedObjectModel (EDL_EmojiModel)

+ (NSManagedObjectModel *)edl_emojiManagedObjectModel {
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel new];
    
    //
    
    NSEntityDescription *emojiEntityDescription = [NSEntityDescription new];
    emojiEntityDescription.name = @"Emoji";
    
    NSAttributeDescription *stringAttributeDescription = [NSAttributeDescription new];
    stringAttributeDescription.optional = NO;
    stringAttributeDescription.name = @"string";
    stringAttributeDescription.attributeType = NSStringAttributeType;
    
    NSAttributeDescription *identifierAttributeDescription = [NSAttributeDescription new];
    identifierAttributeDescription.optional = NO;
    identifierAttributeDescription.name = @"identifier";
    identifierAttributeDescription.attributeType = NSStringAttributeType;
    
    NSRelationshipDescription *childEmojisRelationshipDescription = [NSRelationshipDescription new];
    childEmojisRelationshipDescription.optional = NO;
    childEmojisRelationshipDescription.name = @"childEmojis";
    childEmojisRelationshipDescription.minCount = 0;
    childEmojisRelationshipDescription.maxCount = 0;
    childEmojisRelationshipDescription.deleteRule = NSDenyDeleteRule;
    childEmojisRelationshipDescription.ordered = NO;
    childEmojisRelationshipDescription.destinationEntity = emojiEntityDescription;
    
    NSRelationshipDescription *parentEmojiRelationshipDescription = [NSRelationshipDescription new];
    parentEmojiRelationshipDescription.optional = YES;
    parentEmojiRelationshipDescription.name = @"parentEmoji";
    parentEmojiRelationshipDescription.minCount = 0;
    parentEmojiRelationshipDescription.maxCount = 1;
    parentEmojiRelationshipDescription.deleteRule = NSDenyDeleteRule;
    parentEmojiRelationshipDescription.ordered = NO;
    parentEmojiRelationshipDescription.destinationEntity = emojiEntityDescription;
    
    childEmojisRelationshipDescription.inverseRelationship = parentEmojiRelationshipDescription;
    
    emojiEntityDescription.properties = @[
        stringAttributeDescription,
        identifierAttributeDescription,
        childEmojisRelationshipDescription,
        parentEmojiRelationshipDescription
    ];
    [identifierAttributeDescription release];
    [childEmojisRelationshipDescription release];
    [parentEmojiRelationshipDescription release];
    
    emojiEntityDescription.uniquenessConstraints = @[@[stringAttributeDescription]];
    [stringAttributeDescription release];
    
    //
    
    managedObjectModel.entities = @[emojiEntityDescription];
    [emojiEntityDescription release];
    
    return [managedObjectModel autorelease];
}

@end
