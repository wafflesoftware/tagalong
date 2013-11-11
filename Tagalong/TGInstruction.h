//
//  TGInstruction.h
//  Tagalong
//
//  Created by Jesper on 2013-11-07.
//  Copyright (c) 2013 Jesper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGInstruction : NSObject
@property NSString *tagName;
@property NSString *extName;
@property NSURL *urlToHandlerScript;
@property (readonly) NSUUID *uniqueID;
@end
