//
//  AppController.m
//  PortalHelper
//
//  Created by Ryan Morlok on 11/27/08.
//  Copyright 2008 Morlok Technologies, Inc. All rights reserved.
//

#import "AppController.h"


@implementation AppController

+ (void)initialize
{
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	
	[defaultValues setObject:@"" forKey:EsPathToLoginsXmlFileKey];
	[defaultValues setObject:@"" forKey:EsPathToFileExchangeRootKey];
	[defaultValues setObject:@"http://portal.emergingsoft.com/" forKey:EsBasePortalUrl];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}

- (IBAction)showPreferencePanel:(id)sender
{
	NSLog(@"Displaying preferences window.");
	
	if(!preferencesController)
		preferencesController = [[PreferencesController alloc] init];
	
	[preferencesController showWindow:self];
}

- (IBAction)launchPortalUrl:(id)sender
{
	NSString *portalUrlString = (NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:EsBasePortalUrl];
	NSURL *portalUrl = [NSURL URLWithString:portalUrlString];

	if( !portalUrl )
	{
		NSLog(@"Invalid portal URL specified '%@'.", portalUrlString);
		NSAlert *alert = [NSAlert alertWithMessageText:[NSString stringWithFormat:@"Invalid portal URL '%@'.", portalUrlString] 
										 defaultButton:nil 
									   alternateButton:nil
										   otherButton:nil 
							 informativeTextWithFormat:nil];
		[alert runModal];
		return;
	}
	
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	
	if( ![ws openURL:portalUrl] )
	{
		NSLog(@"Failed to open portal URL.");
		return;
	}
}

- (void)dealloc
{
	[preferencesController release];
	[super dealloc];
}

@end
