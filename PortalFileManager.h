//
//  PortalFileManager.h
//  PortalHelper
//
//  Created by Ryan Morlok on 12/16/08.
//  Copyright 2008 Morlok Technologies, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PortalUser.h"

@interface PortalFileManager : NSObject {

}

- (BOOL)getFolderForUser:(PortalUser*)pu createDirectoryIfNecessary:(NSString**)outputFolder error:(NSError**)error;
- (BOOL)getFolderForUser:(PortalUser*)pu forDate:(NSCalendarDate*)date createDirectoryIfNecessary:(NSString**)outputFolder error:(NSError**)error;
- (BOOL)postFiles:(NSArray*)files forUser:(PortalUser*)pu forDate:(NSCalendarDate*)date error:(NSError**)error;

@end
