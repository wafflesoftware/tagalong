//
//  TGInstruction.m
//  Tagalong
//
//  Created by Jesper on 2013-11-07.
//  Copyright (c) 2013 Jesper. All rights reserved.
//

#import "TGInstruction.h"

@interface TGInstruction () {
    NSUUID *_uniqueID;
}

@end

@implementation TGInstruction

- (NSUUID *)uniqueID {
    if (_uniqueID == nil) {
        _uniqueID = [NSUUID UUID];
    }
    return _uniqueID;
}

#define INSTRUCTION_ERROR_DOMAIN    @"net.wafflesoftware.Tagalong.TGInstruction"
#define TAGNAME_INVALID_CODE    100
#define SCRIPTURL_INVALID_CODE    100

-(BOOL)validateTagName:(id *)ioValue error:(NSError * __autoreleasing *)outError{
    if ((*ioValue == nil) || ![*ioValue isKindOfClass:[NSString class]] || (![(NSString *)*ioValue hasPrefix:@"@"])) {
        if (outError != NULL) {
            NSString *errorString = @"The tag must start with @.";
            NSDictionary *userInfoDict = @{ NSLocalizedDescriptionKey : errorString };
            *outError = [[NSError alloc] initWithDomain:INSTRUCTION_ERROR_DOMAIN
                                                   code:TAGNAME_INVALID_CODE
                                               userInfo:userInfoDict];
        }
        return NO;
    }
    return YES;
}

-(BOOL)validateURLToHandlerScript:(id *)ioValue error:(NSError * __autoreleasing *)outError{
    id value = *ioValue;
    NSString *filePathValue = nil;
    if ([value isKindOfClass:[NSURL class]]) {
        filePathValue = [(NSURL *)value path];
    } else if ([value isKindOfClass:[NSString class]]) {
        filePathValue = (NSString *)value;
    }
    
    BOOL isDir;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePathValue isDirectory:&isDir] && !isDir) {
        return YES;
    }
    
    if (outError != NULL) {
        NSString *errorString = @"The script handler file must be an existing file.";
        NSDictionary *userInfoDict = @{ NSLocalizedDescriptionKey : errorString };
        *outError = [[NSError alloc] initWithDomain:INSTRUCTION_ERROR_DOMAIN
                                               code:SCRIPTURL_INVALID_CODE
                                           userInfo:userInfoDict];
    }
    return NO;

}
@end
