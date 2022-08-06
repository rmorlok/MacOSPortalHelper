//
//  PortalUserManager.h
//  PortalHelper
//
//  Created by Ryan Morlok on 12/20/08.
//  Copyright 2008 Morlok Technologies, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PortalUser.h"

@interface PortalUserManager : NSObject {
	NSMutableArray *portalUsers;
	NSUndoManager *undoManager;
}


- (void)insertObject:(PortalUser*)pu inPortalUsersAtIndex:(NSUInteger)index;
- (void)removeObjectFromPortalUsersAtIndex:(NSUInteger)index;

- (BOOL)saveUserProfiles:(NSError**)error;

+ (PortalUserManager*)sharedManager;

@property(readonly, retain) NSMutableArray *portalUsers;
@property(readonly, retain) NSUndoManager *undoManager;

- (void)observeValueForKeyPath:(NSString*)keyPath 
					  ofObject:(id)object 
						change:(NSDictionary*)change 
					   context:(void*)context;
@end
