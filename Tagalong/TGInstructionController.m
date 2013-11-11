//
//  TGInstructionController.m
//  Tagalong
//
//  Created by Jesper on 2013-11-07.
//  Copyright (c) 2013 Jesper. All rights reserved.
//

#import "TGInstructionController.h"

#import "TGInstruction.h"
#import "TGInstructionApplier.h"

@interface TGInstructionController () {
    NSMutableArray *_instructions;
    NSMutableDictionary *_appliers;
}

@end

@implementation TGInstructionController

static void * const TGInstructionControllerKVOContext = (void*)&TGInstructionControllerKVOContext;

-(void)awakeFromNib {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *instructions = [ud dictionaryForKey:@"instructions"];
    NSMutableArray *instructionsArray = [NSMutableArray array];
    _appliers = [NSMutableDictionary dictionary];
    [instructions enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (![key isKindOfClass:[NSString class]]) return;
        if (![obj isKindOfClass:[NSString class]]) return;
        
        TGInstruction *instruction = [[TGInstruction alloc] init];
        instruction.tagName = (NSString *)key;
        instruction.urlToHandlerScript = [NSURL fileURLWithPath:(NSString *)obj];
        [self startTracking:instruction];
        [instructionsArray addObject:instruction];
    }];
    
    [self willChangeValueForKey:@"instructions"];
    _instructions = instructionsArray;
    [self didChangeValueForKey:@"instructions"];
}

-(void)save {
    NSArray *instructions = [_instructions copy];
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    for (TGInstruction *inst in instructions) {
        if (![self instructionIsValid:inst]) continue;
        d[inst.tagName] = inst.urlToHandlerScript.path;
    }
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:d forKey:@"instructions"];
}

- (BOOL)instructionIsValid:(TGInstruction *)instr {
    id tagName = instr.tagName;
    id urlToHandlerScript = instr.urlToHandlerScript;
    BOOL isValid = ([instr validateValue:&tagName forKey:@"tagName" error:NULL] && [instr validateValue:&urlToHandlerScript forKey:@"urlToHandlerScript" error:NULL]);
    return isValid;
}

- (void)startTracking:(TGInstruction *)instr {
    NSUUID *u = instr.uniqueID;
    TGInstructionApplier *applier = _appliers[u];
    if (applier == nil) {
        applier = [TGInstructionApplier applierWithInstruction:instr];
        _appliers[u] = applier;
    }
    [instr addObserver:self forKeyPath:@"tagName" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:TGInstructionControllerKVOContext];
    [instr addObserver:self forKeyPath:@"urlToHandlerScript" options:NSKeyValueObservingOptionNew context:TGInstructionControllerKVOContext];
    if ([self instructionIsValid:instr]) {
        [applier update];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == TGInstructionControllerKVOContext) {
        if ([object isKindOfClass:[TGInstruction class]]) {
            TGInstruction *instr = object;
            NSUUID *u = instr.uniqueID;
            TGInstructionApplier *applier = _appliers[u];
            if (applier != nil && [self instructionIsValid:instr]) {
                [applier update];
            }
        }
        [self save];
        
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)stopTracking:(TGInstruction *)instr {
    NSUUID *u = instr.uniqueID;
    TGInstructionApplier *applier = _appliers[u];
    if (applier != nil) {
        [applier stop];
    }

    [instr removeObserver:self forKeyPath:@"tagName" context:TGInstructionControllerKVOContext];
    [instr removeObserver:self forKeyPath:@"urlToHandlerScript" context:TGInstructionControllerKVOContext];
}

@dynamic instructions;

-(NSUInteger)countOfInstructions {
    return _instructions.count;
}

-(id)objectInInstructionsAtIndex:(NSUInteger)index {
    return _instructions[index];
}

-(NSArray *)instructionsAtIndexes:(NSIndexSet *)indexes {
    return [_instructions objectsAtIndexes:indexes];
}

-(void)insertObject:(TGInstruction *)object inInstructionsAtIndex:(NSUInteger)index {
    [self startTracking:object];
    [_instructions insertObject:object atIndex:index];
    [self save];
}

-(void)removeObjectFromInstructionsAtIndex:(NSUInteger)index {
    TGInstruction *instruction = _instructions[index];
    [self stopTracking:instruction];
    [_instructions removeObjectAtIndex:index];
    [self save];
}

-(void)replaceObjectInInstructionsAtIndex:(NSUInteger)index withObject:(TGInstruction *)object {
    TGInstruction *instruction = _instructions[index];
    [self stopTracking:instruction];
    [self startTracking:object];
    [_instructions replaceObjectAtIndex:index withObject:object];
    [self save];
}

@end
