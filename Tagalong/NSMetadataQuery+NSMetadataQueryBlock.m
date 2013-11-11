//
//  NSMetadataQuery+NSMetadataQueryBlock.m
//  Cute
//
//  Created by Jesper on 2013-11-06.
//  Copyright (c) 2013 Jesper. All rights reserved.
//

#import "NSMetadataQuery+NSMetadataQueryBlock.h"

typedef void(^OnCancellation)();

@interface NSMetadataQueryBlockRunner : NSObject <NSMetadataQueryDelegate>
@property (copy) NSMetadataQueryResultsHandler handler;
@property (copy) OnCancellation cancellationHandler;
@property NSMetadataQuery *query;
- (instancetype)initWithHandler:(NSMetadataQueryResultsHandler)handler query:(NSMetadataQuery *)query onCancellation:(OnCancellation)c;
@end

@implementation NSMetadataQuery (NSMetadataQueryBlock)

static NSMutableSet *queries = nil;

- (void)startQueryWithResultsHandler:(NSMetadataQueryResultsHandler)handler {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queries = [NSMutableSet set];
    });
    __block NSMetadataQueryBlockRunner *blockRunner = nil;
    blockRunner = [[NSMetadataQueryBlockRunner alloc] initWithHandler:handler query:self onCancellation:^{
        [queries removeObject:blockRunner];
    }];
    [queries addObject:blockRunner];
}

@end

@implementation NSMetadataQueryBlockRunner
- (instancetype)initWithHandler:(NSMetadataQueryResultsHandler)handler
                          query:(NSMetadataQuery *)query
                 onCancellation:(OnCancellation)c
{
    self = [super init];
    if (self) {
        self.handler = handler;
        self.query = query;
        self.cancellationHandler = c;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishGatheringOrUpdating:) name:NSMetadataQueryDidFinishGatheringNotification object:query];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishGatheringOrUpdating:) name:NSMetadataQueryDidUpdateNotification object:query];
        [query startQuery];
    }
    return self;
}

- (void)didFinishGatheringOrUpdating:(NSNotification *)n {
    NSLog(@"stopping updates");
    [self.query disableUpdates];
    NSArray *results = [self.query results];
    BOOL shouldStop = NO;
    self.handler(results, &shouldStop);
    if (shouldStop) {
        [self.query stopQuery];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMetadataQueryDidFinishGatheringNotification object:self.query];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMetadataQueryDidUpdateNotification object:self.query];
        self.cancellationHandler();
    } else {
        NSLog(@"enabling updates");
        [self.query enableUpdates];
    }
}

@end