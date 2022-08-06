//
//  PortalUsersController.m
//  PortalHelper
//
//  Created by Ryan Morlok on 11/27/08.
//  Copyright 2008 EmergingSoft Corporation. All rights reserved.
//

#import "PortalUsersController.h"
#import "PortalUserManager.h"
#import "PreferencesController.h"
#import "PortalUser.h"
#import "Error.h"

@implementation PortalUsersController

- (id)init
{
	if( !(self = [super init]) )
		return nil;
		
	portalFileManager = [[PortalFileManager alloc] init];
	possibleStatusValues = [[NSArray alloc] initWithObjects:@"Trial", @"Customer",nil];
	
	return self;
}

- (void)awakeFromNib
{
    [tableView registerForDraggedTypes:[NSArray arrayWithObject:NSStringPboardType]];
	[[self window] setTitle:@"PortalHelper"];
}

- (PortalUser*)selectedUser
{
	NSArray *selectedUsers = [arrayController selectedObjects];
	
	if( nil == selectedUsers
	   || [selectedUsers count] < 0 )
	{
		NSLog(@"Cannot retrieve selected user because nothing is selected.");
		return nil;
	}
	
	return (PortalUser*)[selectedUsers objectAtIndex:0];
}

- (NSAttributedString*)getLoginInfoForSelectedUser
{
	PortalUser *pu = [self selectedUser];
	
	if( !pu )
		return nil;
	
	//
	// Attributes used to format the text
	//
	NSString *portalUrlString = (NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:EsBasePortalUrl];
	NSURL *portalUrl = [NSURL URLWithString:portalUrlString];
	NSDictionary *linkAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
													portalUrl,										NSLinkAttributeName,
													[NSColor blueColor],							NSForegroundColorAttributeName,
													[NSNumber numberWithInt:NSSingleUnderlineStyle],NSUnderlineStyleAttributeName,
													nil];
	
	NSDictionary *loginPasswordAttributes = [NSDictionary dictionaryWithObject:[NSFont boldSystemFontOfSize:0.0] forKey:NSFontAttributeName];

	//
	// Format the text
	//
	NSAttributedString *attributedPortalUrlString = [[[NSAttributedString alloc] initWithString:portalUrlString attributes:linkAttributes] autorelease];
	NSMutableAttributedString *finalString = [[[NSMutableAttributedString alloc] init] autorelease];
	NSAttributedString *newline = [[[NSAttributedString alloc] initWithString:@"\n"] autorelease];
	
	[finalString appendAttributedString:attributedPortalUrlString];
	[finalString appendAttributedString:newline];
	[finalString appendAttributedString:newline];
	[finalString appendAttributedString:[[[NSAttributedString alloc] initWithString:@"Login: " attributes:loginPasswordAttributes] autorelease]];
	[finalString appendAttributedString:[[[NSAttributedString alloc] initWithString:[pu email]] autorelease]];
	[finalString appendAttributedString:newline];
	[finalString appendAttributedString:[[[NSAttributedString alloc] initWithString:@"Password: " attributes:loginPasswordAttributes] autorelease]];
	[finalString appendAttributedString:[[[NSAttributedString alloc] initWithString:[pu password]] autorelease]];

	return finalString;
}

- (IBAction)viewSelectedUserFolder:(id)sender
{
	NSError *error;
	//
	// Get the user's portal directory, creating if needed.
	//
	NSString *userPortalFolder;
	if( ![portalFileManager getFolderForUser:[self selectedUser] createDirectoryIfNecessary:&userPortalFolder error:&error] )
	{
		NSAlert *alert =  [NSAlert alertWithError:error];
		[alert runModal];
		return;
	}
	
	//
	// Launch finder for the folder
	//
	
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	
	if( ![ws selectFile:userPortalFolder inFileViewerRootedAtPath:userPortalFolder] )
	{
		NSLog(@"Failed to open Finder for user's portal folder '%@'.", userPortalFolder);
		return;
	}
}

- (IBAction)addPortalUser:(id)sender
{
	// Try to end any editing that's taking place
	if( ![[tableView window] makeFirstResponder:[tableView window]] ) {
		NSLog(@"Unable to end editing.");
		return;
	}
	
	// Has edit already occurred in this event?
	NSUndoManager *undo = [self undoManager];
	if( [undo groupingLevel] ) {
		// Close the last group
		[undo endUndoGrouping];
		
		// Open a new group
		[undo beginUndoGrouping];
	}
	
	PortalUser *pu = [[PortalUser alloc] init];
	[pu setTrialStartDate:[NSDate date]];
	
	// Add the new object to the array controller
	[arrayController addObject:pu];
	
	// Resort
	[arrayController rearrangeObjects];
	
	// Get the index of the new object
	int row = [[arrayController arrangedObjects] indexOfObjectIdenticalTo:pu];
	
	// Begin editing the first column
	[tableView editColumn:0 
					  row:row 
				withEvent:nil 
				   select:YES];
}

- (IBAction)save:(id)sender
{
	NSError *error;
	
	if( ![[PortalUserManager sharedManager] saveUserProfiles:&error] )
	{
		NSAlert *alert =  [NSAlert alertWithError:error];
		[alert runModal];
		return;
	}
}

- (IBAction)viewSelectedUserFolderForToday:(id)sender
{
	NSError *error;
	NSString *todaysPortalFolder;

	if( ![portalFileManager getFolderForUser:[self selectedUser] forDate:[NSCalendarDate calendarDate] createDirectoryIfNecessary:&todaysPortalFolder error:&error] )
	{
		NSAlert *alert =  [NSAlert alertWithError:error];
		[alert runModal];
		return;
	}
	
	//
	// Launch finder for the folder
	//
	
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	
	if( ![ws selectFile:todaysPortalFolder inFileViewerRootedAtPath:todaysPortalFolder] )
	{
		NSLog(@"Failed to open Finder for user's portal folder '%@'.", todaysPortalFolder);
		return;
	}
}

- (IBAction)copySelectedUserEmailAddress:(id)sender
{
	// Get the selected user
	PortalUser *selectedUser = [self selectedUser];
	
	if( !selectedUser )
		return;
	
	// Copy the user's email address
	NSPasteboard *pb = [NSPasteboard generalPasteboard];
	
	[pb declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];
	
	[pb setString:[selectedUser email] forType:NSStringPboardType];
}

- (IBAction)copy:(id)sender
{
	// Get the login info
	NSAttributedString *loginInfo = [self getLoginInfoForSelectedUser];
	
	
	NSPasteboard *pb = [NSPasteboard generalPasteboard];
	
	// String only content
	[pb declareTypes:[NSArray arrayWithObjects:NSStringPboardType,NSRTFPboardType,nil] owner:self];
	[pb setString:[loginInfo string] forType:NSStringPboardType];
	[pb setData:[loginInfo RTFFromRange:(NSMakeRange(0, [loginInfo length])) documentAttributes:nil]  forType:NSRTFPboardType];
}

- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)flag
{
	NSLog(@"Checking which types this object supports for dragging.");
	return NSDragOperationCopy;
}

- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard
{
	/*
	NSLog(@"tableView...");	
	// Copy the login data for the selected row
    [pboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];
    [pboard setString:[self getLoginInfoForSelectedUser] forType:NSStringPboardType];
    */
	return YES;
}

- (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation
{
	NSLog(@"Attempting to complete a drop operation.");
	return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id < NSDraggingInfo >)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation
{
	NSLog(@"Table view drop requested.");
	return NO;
}

@synthesize possibleStatusValues;

- (NSMutableArray*) portalUsers
{
	return [[PortalUserManager sharedManager] portalUsers];
}

- (IBAction)postFilesForUser:(id)sender
{
	NSLog(@"Posting files for user.");
	
	PortalUser *pu = [self selectedUser];
	
	if( nil == pu )
	{
		NSLog(@"No user selected.");
		return;
	}
	
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	
	[openPanel setCanChooseDirectories:NO];
	[openPanel setCanChooseFiles:YES];
	[openPanel setCanCreateDirectories:YES];
	[openPanel setAllowsOtherFileTypes:YES];
	[openPanel setAllowsMultipleSelection:YES];
	[openPanel setTitle:[NSString stringWithFormat:@"Select files to post for '%@'...", [pu email]]];
	
	if( NSOKButton == [openPanel runModalForDirectory:nil file:nil types:nil] )
	{
		NSError *error;
		if( ![portalFileManager postFiles:[openPanel filenames] forUser:pu forDate:[NSCalendarDate calendarDate]  error:&error] )
		{
			NSAlert *errorAlert = [NSAlert alertWithError:error];
			[errorAlert runModal];
			return;
		}
	}
	NSLog(@"Finished launching file chooser for file exchange root.");
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window 
{
	return [[PortalUserManager sharedManager] undoManager];
}

- (BOOL)validateMenuItem:(NSMenuItem *)item
{
	if( @selector(copy:) == [item action] )
	{
		if( NSNotFound == [arrayController selectionIndex] )
			return NO;
		else
			return YES;
	}
	
	return YES;
}

- (void)dealloc
{
	NSLog(@"Freeing PortalUsersController");
	[portalFileManager release];
	[possibleStatusValues release];
	[super dealloc];
}

@end
