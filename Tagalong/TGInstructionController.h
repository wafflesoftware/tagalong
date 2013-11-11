//
//  TGInstructionController.h
//  Tagalong
//
//  Created by Jesper on 2013-11-07.
//  Copyright (c) 2013 Jesper. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TGInstructionController : NSObject <NSTableViewDataSource, NSTableViewDelegate>
@property NSArray *instructions;
@end
