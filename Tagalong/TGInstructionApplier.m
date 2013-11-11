//
//  TGInstructionApplier.m
//  Tagalong
//
//  Created by Jesper on 2013-11-08.
//  Copyright (c) 2013 Jesper. All rights reserved.
//

#import "TGInstructionApplier.h"

#import "TGInstruction.h"


// Appear courtesy of https://github.com/jdberry/tag
#import "TagName.h"

NSString* const kMDItemUserTags = @"kMDItemUserTags";

#import "NSMetadataQuery+NSMetadataQueryBlock.h"
#import "NSURL+SOExtendedAttributes.h"

@interface TGInstructionApplier ()
@property (readwrite) NSString *knownTagName;
@property (readwrite) TGInstruction *instruction;
@property NSMetadataQuery *currentQuery;
@property BOOL stopped;
- (instancetype)initWithInstruction:(TGInstruction *)instruction;
@end

@implementation TGInstructionApplier

+ (TGInstructionApplier *)applierWithInstruction:(TGInstruction *)instruction {
    return [[self alloc] initWithInstruction:instruction];
}

- (instancetype)initWithInstruction:(TGInstruction *)instruction
{
    self = [super init];
    if (self) {
        self.instruction = instruction;
    }
    return self;
}

-(void)update {
    self.stopped = NO;
    NSString *prevTagName = self.knownTagName;
    NSString *currTagName = self.instruction.tagName;
    if ([prevTagName isEqualToString:currTagName]) {
        return;
    }
    if (prevTagName != nil) {
        [self uninstallQuery];
    }
    if (currTagName != nil) {
        [self installQuery:currTagName];
    }
}

-(void)stop {
    self.stopped = YES;
    self.knownTagName = nil;
    [self uninstallQuery];
}

- (void)uninstallQuery {
    if (self.currentQuery) {
        [self.currentQuery stopQuery];
        self.currentQuery = nil;
    }
}

- (void)installQuery:(NSString *)newTagName {
    NSMetadataQuery *query = [[NSMetadataQuery alloc] init];
    
    TagName *tagName = [[TagName alloc] initWithTag:newTagName];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K ==[c] %@", kMDItemUserTags, ((TagName*)tagName).visibleName];
    
    [query setPredicate:predicate];
    [query setSearchScopes:@[NSMetadataQueryUserHomeScope]];
    
    NSLog(@"before starting");
    self.knownTagName = newTagName;
    
    [query startQueryWithResultsHandler:^(NSArray *results, BOOL *stop) {
        if (self.stopped) {
            *stop = YES;
            return;
        }
        NSLog(@"new batch of results");
        for (NSMetadataItem *item in results) {
            if (item == nil) continue;
            NSString *path = [item valueForAttribute:(NSString *)kMDItemPath];
            if (path == nil) continue;
            NSLog(@"item: %@", path);
            NSLog(@" - tags: %@", [item valueForAttribute:(NSString *)kMDItemUserTags]);
            
            [self performActionForTag:tagName filePath:path];
            
        }
    }];
    self.currentQuery = query;
}

- (NSMutableSet*)tagSetFromTagArray:(NSArray*)tagArray
{
    NSMutableSet* set = [[NSMutableSet alloc] initWithCapacity:[tagArray count]];
    for (NSString* tag in tagArray)
        [set addObject:[[TagName alloc] initWithTag:tag]];
    return set;
}

- (NSArray*)tagArrayFromTagSet:(NSSet*)tagSet
{
    NSMutableArray* array = [[NSMutableArray alloc] initWithCapacity:[tagSet count]];
    for (TagName* tag in tagSet)
        [array addObject:tag.visibleName];
    return array;
}

//- (void)stripOutTag:(TagName *)tagToRemove fromFilePath:(NSString *)filePath {
//    NSURL *url = [NSURL fileURLWithPath:filePath];
//    
//    NSError *error;
//    
//    
//    NSArray* existingTags;
//    if (![url getResourceValue:&existingTags forKey:NSURLTagNamesKey error:&error])
//        return;
//    
//    // Existing tags minus tags to remove
//    NSMutableSet* tagSet = [self tagSetFromTagArray:existingTags];
//    [tagSet minusSet:[NSSet setWithObject:tagToRemove]];
//    
//    NSArray *revisedTags = [self tagArrayFromTagSet:tagSet];
//    
//    // Set the revised tags onto the item
//    if (![url setResourceValue:revisedTags forKey:NSURLTagNamesKey error:&error])
//        return;
//}

- (NSString *)extensionForTag:(NSString *)tag {
    NSMutableString *cleaning = [tag mutableCopy];
    static NSCharacterSet *clean = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        clean = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyz0123456789-_"] invertedSet];
    });
    NSRange r = NSMakeRange(NSNotFound, 0);
    do {
        r = [cleaning rangeOfCharacterFromSet:clean];
        if (r.location != NSNotFound) {
            [cleaning deleteCharactersInRange:r];
        } else {
            break;
        }
    } while (r.location != NSNotFound);
    return cleaning;
}

- (void)performActionForTag:(TagName *)tagName filePath:(NSString *)filePath {
    //@try {
    NSURL *u = [NSURL fileURLWithPath:filePath];
    
    NSString *extAttributeLastChangeName = @"net.wafflesoftware.Tagalong.lastChange";
    NSString *lastChange = nil;
    
    if ([u hasExtendedAttributeWithName:extAttributeLastChangeName]) {
        lastChange = [u valueOfExtendedAttributeWithName:extAttributeLastChangeName error:NULL];
    }
    
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:NULL];
    NSString *thisChange = [[attrs fileModificationDate] descriptionWithCalendarFormat:nil timeZone:nil locale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    
    if (lastChange != nil) {
        if ([lastChange isEqualToString:thisChange]) {
            return;
        }
    }
    
    NSString *ext = [self extensionForTag:[[tagName visibleName] lowercaseString]];
    if ([ext length] == 0) {
        ext = @"processed";
    }
    
    NSString *tempResultFile = [filePath stringByAppendingPathExtension:ext];
    [@"" writeToFile:tempResultFile atomically:NO encoding:NSUTF8StringEncoding error:NULL];
    NSFileHandle *writingTempResultFile = [NSFileHandle fileHandleForWritingAtPath:tempResultFile];
    
    NSString *launchPath = [self.instruction.urlToHandlerScript path];
    NSTask *task = [[NSTask alloc] init];
    [task setStandardOutput:writingTempResultFile];
    [task setLaunchPath:launchPath];
    [task setArguments:@[filePath]];
    [task launch];
    [task waitUntilExit];
    
    [writingTempResultFile closeFile];
    
    [u setExtendedAttributeValue:thisChange forName:extAttributeLastChangeName error:NULL];
    /*}
     @catch (NSException *exception) {
     
     }
     @finally {
     [self stripOutTag:tagName fromFilePath:filePath];
     }*/
    
}
@end
