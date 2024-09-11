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
        NSFetchRequest<NSManagedObject *> *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Emoji"];
        fetchRequest.sortDescriptors = @[];
        fetchRequest.predicate = nil;
        
        NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        [fetchRequest release];
        fetchedResultsController.delegate = self;
        
        self.managedObjectContext = managedObjectContext;
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

- (void)controller:(NSFetchedResultsController *)controller didChangeContentWithSnapshot:(NSDiffableDataSourceSnapshot<NSString *,NSManagedObjectID *> *)snapshot {
    [_dataSource applySnapshot:snapshot animatingDifferences:YES];
}

@end
