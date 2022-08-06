//
//  PortalUser.m
//  PortalHelper
//
//  Created by Ryan Morlok on 12/2/08.
//  Copyright 2008 EmergingSoft Corporation. All rights reserved.
//

#import "PortalUser.h"


@implementation PortalUser

- (PortalUser*)init
{
	if( nil == (self = [super init]) )
		return nil;
	
	// Default status for new objects is trial.
	[self setStatus:@"Trial"];
	
	return self;
}

@synthesize displayName;
@synthesize email;
@synthesize password;
@synthesize status;
@synthesize trialStartDate;
@synthesize notes;

- (NSString *)description
{
	return [NSString stringWithFormat:@"\"%@\" <%@>", displayName, email];
}

@end
