//
//  PortalUser.h
//  PortalHelper
//
//  Created by Ryan Morlok on 12/2/08.
//  Copyright 2008 Morlok Technologies, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PortalUser : NSObject {
	NSString *displayName;
	NSString *email;
	NSString *password;
	NSString *status;
	NSDate *trialStartDate;
	NSString *notes;
}

@property(retain, readwrite) NSString *displayName;
@property(retain, readwrite) NSString *email;
@property(retain, readwrite) NSString *password;
@property(retain, readwrite) NSString *status;
@property(retain, readwrite) NSDate *trialStartDate;
@property(retain, readwrite) NSString *notes;

@end
