//
//  NSMetadataQuery+NSMetadataQueryBlock.h
//  Cute
//
//  Created by Jesper on 2013-11-06.
//  Copyright (c) 2013 Jesper. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSMetadataQueryResultsSubscriptable;

typedef void(^NSMetadataQueryResultsHandler)(NSArray *results, BOOL *stop);
@interface NSMetadataQuery (NSMetadataQueryBlock)
- (void)startQueryWithResultsHandler:(NSMetadataQueryResultsHandler)handler;
@end