//
//  PortalUserManager.m
//  PortalHelper
//
//  Created by Ryan Morlok on 12/20/08.
//  Copyright 2008 Morlok Technologies, Inc. All rights reserved.
//

#import "PortalUserManager.h"
#import "PreferencesController.h"

@implementation PortalUserManager

static PortalUserManager *sharedPortalUserManager = nil;
static NSString* xmlFileUserPreferencesKeyPath = nil;

+ (PortalUserManager*)sharedManager
{
    @synchronized(self) {
        if (sharedPortalUserManager == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedPortalUserManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedPortalUserManager == nil) {
			
            sharedPortalUserManager = [super allocWithZone:zone];
			xmlFileUserPreferencesKeyPath = [[NSString alloc] initWithFormat:@"values.%@", EsPathToLoginsXmlFileKey];
			
            return sharedPortalUserManager;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

- (BOOL)saveUserProfiles:(NSError**)error
{
	@synchronized(self) {
		NSString *pathToXmlFile = (NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:EsPathToLoginsXmlFileKey];
		
		NSLog(@"Saving user profiles to %@.", pathToXmlFile);
		
		NSXMLElement *loginInformation, *logins;
		NSXMLDocument *xmlDoc = [NSXMLNode documentWithRootElement:(loginInformation = [NSXMLNode elementWithName:@"LoginInformation"])];
		
		[xmlDoc setDocumentContentKind:NSXMLDocumentXMLKind];
		[loginInformation addNamespace:[NSXMLNode namespaceWithName:@"xsd" stringValue:@"http://www.w3.org/2001/XMLSchema"]];
		[loginInformation addNamespace:[NSXMLNode namespaceWithName:@"xsi" stringValue:@"http://www.w3.org/2001/XMLSchema-instance"]];
		
		[loginInformation addChild:(logins = [NSXMLNode elementWithName:@"Logins"])];
		[logins addChild:[NSXMLNode commentWithStringValue:@"Automatically generated with PortalHelper"]];
		
		for(PortalUser *pu in portalUsers)
		{
			NSXMLElement *userNode = [NSXMLNode elementWithName:@"LoginInfo"];
			
			[userNode addChild:[NSXMLNode elementWithName:@"DisplayName"		stringValue:[pu displayName]]];
			[userNode addChild:[NSXMLNode elementWithName:@"Email"				stringValue:[pu email]]];
			[userNode addChild:[NSXMLNode elementWithName:@"Password"			stringValue:[pu password]]];
			[userNode addChild:[NSXMLNode elementWithName:@"LoginLevel"			stringValue:[pu status]]];
			
			if( nil != [pu trialStartDate] ) 
				[userNode addChild:[NSXMLNode elementWithName:@"TrialStartDate"	stringValue:[[pu trialStartDate] descriptionWithCalendarFormat:@"%Y-%m-%d" timeZone:nil locale:nil]]];
			
			if( nil != [pu notes] )
				[userNode addChild:[NSXMLNode elementWithName:@"Notes"			stringValue:[pu notes]]];
			
			// Add it to the document
			[logins addChild:userNode];
		}
		
		NSData *xmlData = [xmlDoc XMLDataWithOptions:NSXMLNodePrettyPrint];
		
		BOOL success =  [xmlData writeToFile:[pathToXmlFile stringByExpandingTildeInPath]
									 options:NSAtomicWrite
									   error:error];
		
		if( success )
			[[self undoManager] removeAllActions];
		
		return success;
	}
	
	return NO;
}

-(void)loadUserProfiles
{
	@synchronized(self) {
		NSString *pathToXmlFile = (NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:EsPathToLoginsXmlFileKey];
		
		NSLog(@"Loading logins data from file '%@'.", pathToXmlFile);
		
		NSData *fileData = [[NSData alloc] initWithContentsOfFile:pathToXmlFile];
		
		if( nil == fileData )
		{
			NSLog(@"Could not load file '%@'.", pathToXmlFile);
			return;
		}
		
		NSError *error;
		NSXMLDocument *xmlDoc = [[NSXMLDocument alloc] initWithData:fileData options:NSXMLDocumentXMLKind error:&error];
		
		if( nil != error)
		{
			[fileData release];
			[xmlDoc release];
			NSLog(@"Error loading XML document. %@", error);
			return;
		}
		
		NSLog(@"Loaded XML document.");
		
		[fileData release];
		fileData = nil;
		
		if( nil == portalUsers )
		{
			[self willChangeValueForKey:@"portalUsers"];
			portalUsers = [[NSMutableArray alloc] init];
			[self didChangeValueForKey:@"portalUsers"];
		}
		
		[self willChangeValueForKey:@"portalUsers"];
		[[self mutableArrayValueForKey:@"portalUsers"] removeAllObjects];
		 
		// Pull out the individuals entries from the XML document
		NSArray *itemNodes = [xmlDoc nodesForXPath:@"LoginInformation/Logins/LoginInfo" error:&error];
		
		[xmlDoc release];
		xmlDoc = nil;
		
		if( nil == itemNodes )
		{
			NSLog(@"Error processing XML document. %@", error);
			return;	
		}
		
		NSLog(@"Retrieved %d user nodes.", [itemNodes count]);
		
		NSMutableArray *tmpPortalUsers = [[[NSMutableArray alloc] init] autorelease];
		 
		for(NSXMLNode *node in itemNodes)
		{
			PortalUser *pu = [[PortalUser alloc] init];
			NSArray *tmp;
			
			if( (tmp = [node nodesForXPath:@"DisplayName" error:&error]) && [tmp count] > 0 )
				[pu setDisplayName:[[tmp objectAtIndex:0] stringValue]];
			
			if( (tmp = [node nodesForXPath:@"Email" error:&error]) && [tmp count] > 0 )
				[pu setEmail:[[tmp objectAtIndex:0] stringValue]];
			
			if( (tmp = [node nodesForXPath:@"Password" error:&error]) && [tmp count] > 0 )
				[pu setPassword:[[tmp objectAtIndex:0] stringValue]];
			
			if( (tmp = [node nodesForXPath:@"LoginLevel" error:&error]) && [tmp count] > 0 )
				[pu setStatus:[[tmp objectAtIndex:0] stringValue]];
			
			if( (tmp = [node nodesForXPath:@"TrialStartDate" error:&error]) && [tmp count] > 0 )
				[pu setTrialStartDate:[NSCalendarDate dateWithString:[[tmp objectAtIndex:0] stringValue] calendarFormat:@"%Y-%m-%d"]];
			
			if( (tmp = [node nodesForXPath:@"Notes" error:&error]) && [tmp count] > 0 )
				[pu setNotes:[[tmp objectAtIndex:0] stringValue]];
			
			[tmpPortalUsers addObject:pu];
		}
		
		NSLog(@"Adding %d users to portalUsers array.", [tmpPortalUsers count]);
		[[self mutableArrayValueForKey:@"portalUsers"] addObjectsFromArray:tmpPortalUsers];
		[self didChangeValueForKey:@"portalUsers"];
		
		// We've just added a lot of users in a way that should be able to be undone
		[[self undoManager] removeAllActions];
	}
}

- (void)startObservingPortalUser:(PortalUser*)pu
{
	[pu addObserver:self 
		 forKeyPath:@"displayName" 
			options:NSKeyValueObservingOptionOld 
			context:NULL];
	
	[pu addObserver:self 
		 forKeyPath:@"email" 
			options:NSKeyValueObservingOptionOld 
			context:NULL];
	
	[pu addObserver:self 
		 forKeyPath:@"password" 
			options:NSKeyValueObservingOptionOld 
			context:NULL];
	
	[pu addObserver:self 
		 forKeyPath:@"status" 
			options:NSKeyValueObservingOptionOld 
			context:NULL];
	
	[pu addObserver:self 
		 forKeyPath:@"trialStartDate" 
			options:NSKeyValueObservingOptionOld 
			context:NULL];
	
	[pu addObserver:self 
		 forKeyPath:@"notes" 
			options:NSKeyValueObservingOptionOld 
			context:NULL];	
}

- (void)stopObservingPortalUser:(PortalUser*)pu
{
	[pu removeObserver:self 
			forKeyPath:@"displayName"];
	
	[pu removeObserver:self 
			forKeyPath:@"email"];
	
	[pu removeObserver:self 
			forKeyPath:@"password"];
	
	[pu removeObserver:self 
			forKeyPath:@"status"];
	
	[pu removeObserver:self 
			forKeyPath:@"trialStartDate"];
	
	[pu removeObserver:self 
			forKeyPath:@"notes"];
}

- (void)insertObject:(PortalUser*)pu inPortalUsersAtIndex:(NSUInteger)index
{
	NSLog(@"Adding %@ to PortalUsers.", pu);
	
	// Add the inverse operation to the undo stack
	NSUndoManager *undo = [self undoManager];
	[[undo prepareWithInvocationTarget:self] removeObjectFromPortalUsersAtIndex:index];
	
	if( ![undo isUndoing] ) {
		[undo setActionName:@"Insert Portal User"];
	}
	
	[self startObservingPortalUser:pu];
	[portalUsers insertObject:pu atIndex:index];
}

- (void)removeObjectFromPortalUsersAtIndex:(NSUInteger)index
{
	PortalUser *pu = [portalUsers objectAtIndex:index];
	
	NSLog(@"Removing portal user '%@'.", pu);
	
	// Add the inverse operation to the undo manager
	NSUndoManager *undo = [self undoManager];
	[[undo prepareWithInvocationTarget:self] insertObject:pu inPortalUsersAtIndex:index];
	
	if( ![undo isUndoing] ) {
		[undo setActionName:@"Delete Portal User"];
	}
	
	[self stopObservingPortalUser:pu];
	[portalUsers removeObjectAtIndex:index];
}

- (PortalUserManager*)init
{
	if( nil == (self = [super init]) )
		return nil;
	
	// Create the undo manager for portal users
	undoManager = [[NSUndoManager alloc] init];
	
	// Register to find out when the user profile XML path changes
	NSLog(@"Registering to recieve updates to logins file location.");
	[[NSUserDefaultsController sharedUserDefaultsController] addObserver:self 
															  forKeyPath:xmlFileUserPreferencesKeyPath
																 options:NSKeyValueObservingOptionOld 
																 context:nil];
	
	// Attempt an initial load of portalUsers.
	[self loadUserProfiles];
	
	NSLog(@"Done initializing PortalUserManager.");
	return self;
}

- (void)changeKeyPath:(NSString*)keyPath 
			 ofObject:(id)object 
			  toValue:(id)value
{
	[object setValue:value forKeyPath:keyPath];
}

- (void)observeValueForKeyPath:(NSString*)keyPath 
					  ofObject:(id)object 
						change:(NSDictionary*)change 
					   context:(void*)context
{
	NSLog(@"Observed change for key path '%@'.", keyPath);
	
	if( [xmlFileUserPreferencesKeyPath isEqualToString:keyPath] ) {
		// Reload the data...
		NSLog(@"Reloading portal users because XML file changed.");
		[self loadUserProfiles];
	} else {
		// Change to a PortalUser
		NSUndoManager *undo = [self undoManager];
		
		id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
		
		if( oldValue == [NSNull null] ) {
			oldValue = nil;
		}
		
		[[undo prepareWithInvocationTarget:self] changeKeyPath:keyPath ofObject:object toValue:oldValue];
	}
}

#pragma mark portalUsers Property
@synthesize portalUsers;

@synthesize undoManager;
	
- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (unsigned)retainCount
{
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release
{
    // do nothing
}

- (id)autorelease
{
    return self;
}

- (void)dealloc
{
	// Stop listening for changes to the location of the XML file
	[[[NSUserDefaultsController sharedUserDefaultsController] values] removeObserver:self 
																		  forKeyPath:EsPathToLoginsXmlFileKey];
	
	for(PortalUser* pu in portalUsers)
	{
		[self stopObservingPortalUser:pu];
	}
	
	[portalUsers release];
	[undoManager release];
	[super dealloc];
}
@end
