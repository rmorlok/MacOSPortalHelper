//
//  PreferencesController.m
//  PortalHelper
//
//  Created by Ryan Morlok on 11/27/08.
//  Copyright 2008 Morlok Technologies, Inc. All rights reserved.
//

#import "PreferencesController.h"

NSString * const EsPathToLoginsXmlFileKey    = @"LoginsXmlFilePath";
NSString * const EsPathToFileExchangeRootKey = @"FileExchangeRootPath";
NSString * const EsBasePortalUrl			 = @"BasePortalUrl";

@implementation PreferencesController

- (id)init
{
	NSLog(@"Initializing the preferences window.");
	return (self = [super init]);
}

- (NSString*)windowNibName
{
	return @"Preferences";
}

- (void)showWindow:(id)sender
{
	NSLog(@"Showing Preferences window.");
	NSLog(@"Is window displayed? %d", [[self window] isVisible]);
	[super showWindow:sender];
	[[self window] makeKeyAndOrderFront:self];
	NSLog(@"Is window displayed now? %d", [[self window] isVisible]);
}

- (void)windowDidLoad
{
	NSLog(@"Preferences NIB file loaded.");
}

- (IBAction)chooseLoginsXmlFile:(id)sender
{
	NSLog(@"Choosing logins XML file.");
	
	NSArray *fileTypes = [NSArray arrayWithObjects:@"xml", nil];
	
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	
	[openPanel setCanChooseDirectories:NO];
	[openPanel setCanChooseFiles:YES];
	[openPanel setCanCreateDirectories:YES];
	[openPanel setAllowsOtherFileTypes:YES];
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setTitle:@"Select login XML file"];
	
	if( NSOKButton == [openPanel runModalForDirectory:nil file:nil types:fileTypes] )
	{
		[[NSUserDefaults standardUserDefaults] setObject:[openPanel filename] forKey:EsPathToLoginsXmlFileKey];
	}
	NSLog(@"Finished launching file chooser for file exchange root.");
}

- (IBAction)chooseFileExchangeRoot:(id)sender
{
	NSLog(@"Choosing file exchange root.");
	
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	
	[openPanel setCanChooseDirectories:YES];
	[openPanel setCanChooseFiles:NO];
	[openPanel setCanCreateDirectories:YES];
	[openPanel setAllowsOtherFileTypes:YES];
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setTitle:@"Select file exchange root"];
	
	if( NSOKButton == [openPanel runModalForDirectory:nil file:nil types:nil] )
	{
		[[NSUserDefaults standardUserDefaults] setObject:[openPanel filename] forKey:EsPathToFileExchangeRootKey];
	}
	
	NSLog(@"Finished launching file chooser for file exchange root.");
}

- (void)windowWillClose:(NSNotification *)notification
{
	// Try to end any editing that may be happening.
	[[self window] makeFirstResponder:[self window]];
}
@end
