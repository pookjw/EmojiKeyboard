//
//  EmojisViewModel.m
//  EmojiKeyboardExtension
//
//  Created by Jinwoo Kim on 9/11/24.
//

#import "EmojisViewModel.h"
#import "NSManagedObjectModel+EDL_EmojiModel.h"
#import <objc/message.h>
#import <objc/runtime.h>

@interface EmojisViewModel () <NSFetchedResultsControllerDelegate>
@property (retain, nonatomic, readonly) UICollectionViewDiffableDataSource<NSString *, NSManagedObjectID *> *dataSource;
@property (retain, nonatomic, nullable) NSManagedObjectContext *managedObjectContext;
@property (retain, nonatomic, nullable) NSManagedObjectContext *mainManagedObjectContext;
@property (retain, nonatomic, nullable) NSFetchedResultsController<NSManagedObject *> *fetchedResultsController;
@end

@implementation EmojisViewModel

- (instancetype)initWithDataSource:(UICollectionViewDiffableDataSource<NSString *, NSManagedObjectID *> *)dataSource {
    if (self = [super init]) {
        _dataSource = [dataSource retain];
    }
    
    return self;
}

- (void)dealloc {
    [_dataSource release];
    [_managedObjectContext release];
    [_mainManagedObjectContext release];
    [_fetchedResultsController release];
    [super dealloc];
}

- (void)loadDataSourceWithCompletionHandler:(void (^)(NSError * _Nullable))completionHandler {
    NSURL *containerURL = [NSBundle.mainBundle URLForResource:@"container" withExtension:@"sqlite"];
    
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel edl_emojiManagedObjectModel];
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    
    NSPersistentStoreDescription *storeDescription = [[NSPersistentStoreDescription alloc] initWithURL:containerURL];
    storeDescription.type = NSSQLiteStoreType;
    reinterpret_cast<void (*)(id, SEL, BOOL)>(objc_msgSend)(storeDescription, sel_registerName("setShouldInvokeCompletionHandlerConcurrently:"), NO);
    storeDescription.shouldAddStoreAsynchronously = YES;
    storeDescription.shouldMigrateStoreAutomatically = NO;
    storeDescription.shouldInferMappingModelAutomatically = NO;
    storeDescription.readOnly = YES;
    
    __weak auto weakSelf = self;
    
    [persistentStoreCoordinator addPersistentStoreWithDescription:storeDescription completionHandler:^(NSPersistentStoreDescription * _Nonnull desc, NSError * _Nullable error) {
        assert(NSThread.isMainThread);
        
        if (error != nil) {
            completionHandler(error);
            return;
        }
        
        auto unretained = weakSelf;
        if (unretained == nil) {
            completionHandler(nil);
            return;
        }
        
        //
        
        NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator;
        
        NSManagedObjectContext *mainManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        mainManagedObjectContext.parentContext = managedObjectContext;
        
        NSFetchRequest<NSManagedObject *> *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Emoji"];
        fetchRequest.sortDescriptors = @[];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K == NULL" argumentArray:@[@"parentEmoji"]];
        
        NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        [fetchRequest release];
        fetchedResultsController.delegate = self;
        
        self.managedObjectContext = managedObjectContext;
        self.mainManagedObjectContext = mainManagedObjectContext;
        [mainManagedObjectContext release];
        self.fetchedResultsController = fetchedResultsController;
        
        [managedObjectContext performBlock:^{
            NSError * _Nullable error = nil;
            [fetchedResultsController performFetch:&error];
            completionHandler(error);
        }];
        
        [managedObjectContext release];
        [fetchedResultsController release];
    }];
    
    [storeDescription release];
}

- (NSArray<NSString *> *)main_childEmojiStringsAtIndexPath:(NSIndexPath *)indexPath identifiersOut:(NSArray<NSString *> * _Nonnull *)identifiersOut {
    NSManagedObjectID *managedObjectID = [_fetchedResultsController objectAtIndexPath:indexPath].objectID;
    NSManagedObject *managedObject = [_mainManagedObjectContext objectWithID:managedObjectID];
    NSSet<NSManagedObject *> *childEmojis = [managedObject valueForKey:@"childEmojis"];
    
    NSMutableArray<NSString *> *emojiStrings = [[NSMutableArray alloc] initWithCapacity:childEmojis.count];
    NSMutableArray<NSString *> *identifiers = [[NSMutableArray alloc] initWithCapacity:childEmojis.count];
    
    for (NSManagedObject *childEmoji in childEmojis) {
        NSString *string = [childEmoji valueForKey:@"string"];
        NSString *identifier = [childEmoji valueForKey:@"identifier"];
        [emojiStrings addObject:string];
        [identifiers addObject:identifier];
    }
    
    if (identifiersOut != nullptr) {
        *identifiersOut = [identifiers autorelease];
    }
    
    return [emojiStrings autorelease];
}

- (NSManagedObject *)managedObjectAtIndexPath:(NSIndexPath *)indexPath {
    return [_fetchedResultsController objectAtIndexPath:indexPath];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeContentWithSnapshot:(NSDiffableDataSourceSnapshot<NSString *,NSManagedObjectID *> *)snapshot {
    [_dataSource applySnapshot:snapshot animatingDifferences:YES];
}

@end
