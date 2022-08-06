//
//  AppDelegate.m
//  PortalHelper
//
//  Created by Ryan Morlok on 12/16/08.
//  Copyright 2008 Morlok Technologies, Inc. All rights reserved.
//

#import "AppDelegate.h"


@implementation AppDelegate

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filename
{
	NSLog(@"Application was requested to open %d files.", [filename count]);
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication 
					hasVisibleWindows:(BOOL)flag
{
	NSLog(@"Got reopen request.");
	
	[self showPortalUsersWindow:self];
	return NO;
}

- (void)showPortalUsersWindow:(id)sender
{
	[[portalUsersController window] makeKeyAndOrderFront:sender];
}

@end
