//
//  main.mm
//  EmojiScript
//
//  Created by Jinwoo Kim on 9/7/24.
//

#import <CoreData/CoreData.h>
#import "ESArgumentParser.h"
#import "ESEmojiToken.h"
#import "NSManagedObjectModel+EDL_EmojiModel.h"

void assertEmojiTokensValidation(NSArray<ESEmojiToken *> *emojiTokens, NSArray<ESEmojiToken *> *emojiZWJSequencesTokens, NSDictionary<ESEmojiToken *, NSArray<ESEmojiToken *> *> *emojiTokenReferences) {
    NSMutableSet<ESEmojiToken *> *tokens = [NSMutableSet new];
    __block NSUInteger count = 0;
    
    for (ESEmojiToken *token in emojiTokens){
        [tokens addObject:token];
        count += 1;
    }
    
    assert(tokens.count == count);
    
    for (ESEmojiToken *token in emojiZWJSequencesTokens){
        [tokens addObject:token];
        count += 1;
    }
    
    assert(tokens.count == count);
    
    //
    
    [emojiTokenReferences enumerateKeysAndObjectsUsingBlock:^(ESEmojiToken * _Nonnull key, NSArray<ESEmojiToken *> * _Nonnull obj, BOOL * _Nonnull stop) {
        NSLog(@"%@ (%@; %@), isZWJ: %d", key.string, key.trimmedIdentifier, key.identifier, key.emojiType == ESEmojiTokenZWJSequence);
        
        assert([tokens containsObject:key]);
        [tokens removeObject:key];
        
        [obj enumerateObjectsUsingBlock:^(ESEmojiToken * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"    - %@ (%@; %@), isZWJ: %d", obj.string, obj.trimmedIdentifier, obj.identifier, obj.emojiType == ESEmojiTokenZWJSequence);
            assert([tokens containsObject:obj]);
            [tokens removeObject:obj];
        }];
        
    }];
    
    assert(tokens.count == 0);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSURL * _Nullable emojiSequencesURL = [ESArgumentParser emojiSequencesURL];
        NSURL * _Nullable emojiZWJSequencesURL = [ESArgumentParser emojiZWJSequencesURL];
        NSURL * _Nullable outputStoreURL = [ESArgumentParser outputStoreURL];
        
        if ((emojiSequencesURL == nil) || (emojiSequencesURL == nil) || (outputStoreURL == nil)) {
            NSLog(@"%@", ESArgumentParser.helpMessage);
            return EXIT_FAILURE;
        }
        
        if ([NSFileManager.defaultManager fileExistsAtPath:outputStoreURL.path]) {
            NSLog(@"Already %@ exists. Please remove it and try again.", [outputStoreURL path]);
            return EXIT_FAILURE;
        }
        
        //
        
        NSArray<ESEmojiToken *> *emojiTokens = [ESEmojiToken emojiTokensFromURL:emojiSequencesURL];
        NSArray<ESEmojiToken *> *emojiZWJSequencesTokens = [ESEmojiToken emojiTokensFromURL:emojiZWJSequencesURL];
        
        NSDictionary<ESEmojiToken *, NSArray<ESEmojiToken *> *> *emojiTokenReferences = [ESEmojiToken emojiTokenReferencesFromEmojiTokens:[emojiTokens arrayByAddingObjectsFromArray:emojiZWJSequencesTokens]];
        
        assertEmojiTokensValidation(emojiTokens, emojiZWJSequencesTokens, emojiTokenReferences);
        
        //
        
        NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel edl_emojiManagedObjectModel];
        NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
        
        NSPersistentStoreDescription *storeDescription = [[NSPersistentStoreDescription alloc] initWithURL:outputStoreURL];
        storeDescription.type = NSSQLiteStoreType;
        storeDescription.shouldAddStoreAsynchronously = NO;
        storeDescription.shouldMigrateStoreAutomatically = NO;
        storeDescription.shouldInferMappingModelAutomatically = NO;
        
        [persistentStoreCoordinator addPersistentStoreWithDescription:storeDescription completionHandler:^(NSPersistentStoreDescription * _Nonnull desc, NSError * _Nullable error) {
            assert(error == nil);
        }];
        [storeDescription release];
        
        NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator;
        
        NSEntityDescription *emojiEntityDescription = managedObjectModel.entitiesByName[@"Emoji"];
        [emojiTokenReferences enumerateKeysAndObjectsUsingBlock:^(ESEmojiToken * _Nonnull parentEmojiToken, NSArray<ESEmojiToken *> * _Nonnull childEmojiTokens, BOOL * _Nonnull stop) {
            NSManagedObject *parentEmojiManagedObject = [[NSManagedObject alloc] initWithEntity:emojiEntityDescription insertIntoManagedObjectContext:managedObjectContext];
            
            [parentEmojiManagedObject setValue:parentEmojiToken.string forKey:@"string"];
            [parentEmojiManagedObject setValue:parentEmojiToken.identifier forKey:@"identifier"];
            
            [childEmojiTokens enumerateObjectsUsingBlock:^(ESEmojiToken * _Nonnull childEmojiToken, NSUInteger idx, BOOL * _Nonnull stop) {
                NSManagedObject *childManagedObject = [[NSManagedObject alloc] initWithEntity:emojiEntityDescription insertIntoManagedObjectContext:managedObjectContext];
                
                [childManagedObject setValue:childEmojiToken.string forKey:@"string"];
                [childManagedObject setValue:childEmojiToken.identifier forKey:@"identifier"];
                [childManagedObject setValue:parentEmojiManagedObject forKey:@"parentEmoji"];
                [childManagedObject release];
            }];
            
            [parentEmojiManagedObject release];
        }];
        
        [persistentStoreCoordinator release];
        
        NSError * _Nullable error = nil;
        [managedObjectContext save:&error];
        assert(error == nil);
        
        //
        
        return EXIT_SUCCESS;
    }
}
