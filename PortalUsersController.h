//
//  PortalUsersController.h
//  PortalHelper
//
//  Created by Ryan Morlok on 11/27/08.
//  Copyright 2008 EmergingSoft Corporation. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PortalUser.h"
#import "PortalFileManager.h"

@interface PortalUsersController : NSWindowController {
	IBOutlet NSTableView *tableView;
	IBOutlet NSArrayController *arrayController;
	NSString *searchString;
	PortalFileManager *portalFileManager;
	NSArray *possibleStatusValues;
}

- (IBAction)viewSelectedUserFolder:(id)sender;
- (IBAction)viewSelectedUserFolderForToday:(id)sender;
- (IBAction)copySelectedUserEmailAddress:(id)sender;
- (IBAction)copy:(id)sender;
- (IBAction)postFilesForUser:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)addPortalUser:(id)sender;

@property(readonly, retain) NSMutableArray *portalUsers;
@property(readonly, retain) NSArray *possibleStatusValues;

- (PortalUser*)selectedUser;

#pragma mark NSWindow delegate methods
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window;

#pragma mark Table View Drag and Drop
- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)flag;
- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard;
- (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation;
- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id < NSDraggingInfo >)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation;

@end
