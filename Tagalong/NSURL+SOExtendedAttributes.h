/*
 NSURL+SOExtendedAttributes
 
 Copyright 2012 Standard Orbit Software, LLC. All rights reserved.
 License at the bottom of the file.
 */

#import <Foundation/Foundation.h>
#import <Availability.h>

#if TARGET_OS_IPHONE
#ifndef __IPHONE_5_0
#warning "This project uses features only available in iOS SDK 5.0 and later."
#endif
#elif TARGET_OS_MAC
#ifndef __MAC_10_7
#warning "This project uses features only available in Mac OS X SDK 10.7 and later."
#endif
#endif

/**
 The SOExtendedAttributes category on NSURL enables retrieving and manipulating the extended attributes on a file system item.
 
 These methods are valid only on file URLs. An NSInternalInconsistencyException is thrown if invoked an a non-file URL.
 
 Internally, they're implemented using [listxattr(2)](x-man-page://listxattr), [getxattr(2)](x-man-page://getxattr), [setxattr(2)](x-man-page://setxattr), and [removexattr(2)](x-man-page://removexattr).
 
 ** Compatibility **
 
 SOExtendedAttributes is compatible with Mac OS X 10.6+ and iOS 5. The clang compiler is required. The source file `NSURL+SOExtendedAttributes.m` must be compiled with ARC enabled. For an alternate Cocoa implementation compatible with Mac OS X 10.4 and greater, see [UKXattrMetadataStore](http://zathras.de/angelweb/sourcecode.htm).
 
 ** Symbolic links **
 
 These methods act on the explicitly given URL. If that URL is to a symbolic link, you'll be manipulating extended attributes on the symlink, not its original file. Use `-URLByResolvingSymlinksInPath` to obtain a URL for which points to the original file system item.
 
 ** Use with iCloud Backup **
 
 iCloud (as of iOS 5.0.1) honors the extended attribute `@"com.apple.MobileMeBackup"` as a flag to exclude a file system item from iCloud backup. This category defines the constant `iCloudDoNotBackupAttributeName` to work with this iCloud behavior.
 
 ** Constants **
 
 `iCloudDoNotBackupAttributeName = @"com.apple.MobileMeBackup"`
 
 E.g. To determine if a file system item is marked to be excluded from iCloud backup:
 
    NSURL fileURL = ...;
    BOOL isExcludedFromiCloudBackup = [fileURL hasExtendedAttributeWithName:iCloudDoNotBackupAttribute];
 
 */

extern NSString * const iCloudDoNotBackupAttributeName;
extern NSString * const SOExtendedAttributesErrorDomain;

enum {
    SOExtendedAttributesValueCantBeSerialized = 1968,
    SOExtendedAttributesSetValueError,
    SOExtendedAttributesGetValueError,
};


@interface NSURL (SOExtendedAttributes)

/** @name Accessing attributes in batches */

/** Returns the extended attributes of the file system item at this URL.
 
 Return all extended attributes that the current user account has permission to access. Attributes will include the HFS compression extended attribute if present.
 
 @param outError A pointer to an error object. On return, if an error has occurred, this pointer references an actual error object containing the error information. Pass NULL if you're not interesting in error reporting.
 @return An NSDictionary object that describes the extended attributes of the file system object, or nil if an error occurred.
 */
- (NSDictionary *) extendedAttributesWithError:(NSError * __autoreleasing *)outError;

/** Sets the extended attribute values for the given URL.
 
 The attributes dictionary parameter may contain any object value that can be encoded as a property list.
 
 If the attributes dictionary holds a value object that cannot be encoded as a plist, an NSError with code `SOExtendedAttributesValueCantBeSerialized` is returned via the outError parameter. 
 
 On error, a partial number of the given extended attributes may have been successfully set. The error returned through outError will indicate which attributes could not be set. In particular, `[[*outError userInfo] objectForKey:NSUnderlyingErrorKey]`
 
 @param attributes The extended attribute names and values to be set. All values be instances of NSData, NSString, NSArray, NSDictionary, NSDate or NSNumber.
 @param outError A pointer to an error object. On return, if an error has occurred, this pointer references an actual error object containing the error information. Pass NULL if you're not interesting in error reporting.
 @return YES if all given attribute values were set. NO if there was an error setting one or more of the values.
 */
- (BOOL) setExtendedAttributes:(NSDictionary *)attributes error:(NSError * __autoreleasing *)outError;


/** @name Accessing attributes individually */

/** Returns YES if the file system item has the named attribute.
 
 Sometimes, you're only interested in the presence or absence of an extended attribute on a given URL. E.g. @"com.apple.MobileMeBackup".
 
 @param name The name of the extended attribute. Throws `NSInvalidArgumentException` if name is nil or empty.
 @return YES if the named extended attribute is present on the URL; NO otherwise.
 */
- (BOOL) hasExtendedAttributeWithName:(NSString *)name;

/** Returns the value of the named extended attribute from this file system item.
 
 @param name The name of the extended attribute. Throws `NSInvalidArgumentException` if name is nil or empty.
 @param outError A pointer to an error object. On return, if an error has occurred, this pointer references an actual error object containing the error information. Pass NULL if you're not interesting in error reporting.
 @return An appropriate Foundation object holding the value, or nil if there was an error.
 */
- (id) valueOfExtendedAttributeWithName:(NSString *)name error:(NSError * __autoreleasing *)outError;

/** Set the value of the named extended attribute.
 
 @param value The value to be set. Must be an instance of NSData, NSString, NSArray, NSDictionary, NSDate or NSNumber.
 @param name The name of the extended attribute. Throws `NSInvalidArgumentException` if name is nil or empty.
 @param outError A pointer to an error object. On return, if an error has occurred, this pointer references an actual error object containing the error information. Pass NULL if you're not interesting in error reporting.
 @return YES if the given value was set; NO if there was an error.
 */
- (BOOL) setExtendedAttributeValue:(id)value forName:(NSString *)name error:(NSError * __autoreleasing *)outError;


/** @name Removing an extended attribute */

/** Removes the named extended attribute from this file system item.
 
 @param name The name of the extended attribute. Throws `NSInvalidArgumentException` if name is nil or empty.
 @param outError A pointer to an error object. On return, if an error has occurred, this pointer references an actual error object containing the error information. Pass NULL if you're not interesting in error reporting.
 @return YES if successfully removed or named attribute does not exist. NO if there was an error.
 */
- (BOOL) removeExtendedAttributeWithName:(NSString *)name error:(NSError * __autoreleasing *)outError;


@end

/*
 Copyright (c) 2012, Standard Orbit Software, LLC. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 Neither the name of the Standard Orbit Software, LLC nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
