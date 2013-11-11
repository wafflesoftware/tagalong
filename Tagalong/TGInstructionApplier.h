//
//  TGInstructionApplier.h
//  Tagalong
//
//  Created by Jesper on 2013-11-08.
//  Copyright (c) 2013 Jesper. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TGInstruction;

@interface TGInstructionApplier : NSObject
+ (TGInstructionApplier *)applierWithInstruction:(TGInstruction *)instruction;
@property (readonly) NSString *knownTagName;
@property (readonly) TGInstruction *instruction;
- (void)update;
- (void)stop;
@end
