  //
  //  PXPaletteController.m
  //  Pixen
  //
  //  Created by Joe Osborn on 2007.12.12.
  //  Copyright 2007 Pixen. All rights reserved.
  //

#import "PXPaletteController.h"

#import "PXToolSwitcher.h"
#import "PXToolPaletteController.h"
#import "PXCanvas.h"
#import "PXCanvas_Layers.h"
#import "PXPalette.h"
#import "PXDocument.h"
#import "PXPaletteView.h"

@implementation PXPaletteController

- (id)init
{
	self = [super initWithNibName:@"PXPaletteController" bundle:nil];
	
	frequencyPalette = PXPalette_initWithoutBackgroundColor(PXPalette_alloc());
	recentLimit = 32;
	recentPalette = PXPalette_initWithoutBackgroundColor(PXPalette_alloc());
	mode = PXPaletteModeFrequency;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPalette:) name:@"PXCanvasFrequencyPaletteRefresh" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePalette:) name:@"PXCanvasPaletteUpdate" object:nil];
	
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	PXPalette_release(frequencyPalette);
	PXPalette_release(recentPalette);
	[super dealloc];
}

- (void)awakeFromNib
{
	paletteView.highlightEnabled = NO;
}

- (void)setDocument:(PXDocument *)doc
{
	[paletteView setDocument:doc];
	document = doc;
	[self refreshPalette:nil];
}

- (void)refreshPalette:(NSNotification *)note
{
	if(![document containsCanvas:[note object]])
	{
		return;
	}
	
	PXPalette *oldPal = frequencyPalette;
	frequencyPalette = [[note object] createFrequencyPalette];
	PXPalette_release(oldPal);
	if(mode == PXPaletteModeFrequency)
	{
		[paletteView setPalette:frequencyPalette];
	}
}

- (void)addRecentColor:(NSColor *)c
{
	NSUInteger idx = PXPalette_indexOfColor(recentPalette, c);
	if(idx != NSNotFound)
	{
		if(idx != 0)
		{
			PXPalette_removeColorAtIndex(recentPalette, idx);
			PXPalette_insertColorAtIndex(recentPalette, c, 0);
		}
	}
	else
	{
		PXPalette_insertColorAtIndex(recentPalette, c, 0);
		while(PXPalette_colorCount(recentPalette) > recentLimit)
		{
			PXPalette_removeColorAtIndex(recentPalette, PXPalette_colorCount(recentPalette)-1);
		}
	}
}

- (void)updatePalette:(NSNotification *)note
{
	if(![document containsCanvas:[note object]])
	{
		return;
	}
	NSDictionary *changes = [note userInfo];
	//for each canvas
	NSCountedSet *oldC = [changes objectForKey:@"PXCanvasPaletteUpdateRemoved"];
	NSCountedSet *newC = [changes objectForKey:@"PXCanvasPaletteUpdateAdded"];
	for(NSColor *old in oldC)
	{
		// NSLog(@"Color %@ was removed %d times", old, [oldC countForObject:old]);
		PXPalette_decrementColorCount(frequencyPalette, old, [oldC countForObject:old]);
	}
	//can do 'recent palette' stuff here too. most draws will consist of one new and many old, so just consider the last 100 new?
	for(NSColor *new in newC)
	{
		//NSLog(@"Color %@ was added %d times", new, [newC countForObject:new]);
		PXPalette_incrementColorCount(frequencyPalette, new, [newC countForObject:new]);
		[self addRecentColor:new];
	}
	[paletteView setNeedsRetile];
}

- (void)useColorAtIndex:(NSUInteger)index
{
	PXToolSwitcher *switcher = [[PXToolPaletteController sharedToolPaletteController] leftSwitcher];
	
	if ([NSEvent pressedMouseButtons] == 2 || ([NSEvent modifierFlags] & NSControlKeyMask))
	{
		switcher = [[PXToolPaletteController sharedToolPaletteController] rightSwitcher];
	}
	
	[switcher setColor:PXPalette_colorAtIndex(frequencyPalette, index)];	
}

- (void)paletteViewSizeChangedTo:(NSControlSize)size
{
	[[NSUserDefaults standardUserDefaults] setInteger:size forKey:PXColorPickerPaletteViewSizeKey];
}

- (BOOL)isPaletteIndexKey:(NSEvent *)event
{
	NSString *chars = [event characters];
	//not sure why numpad is unacceptable, but whatever
	BOOL numpad = [event modifierFlags] & NSNumericPadKeyMask;
	return (([chars intValue] != 0) || ([chars characterAtIndex:0] == '0')) && !numpad;
}

- (void)keyDown:(NSEvent *)event
{
	NSString *chars = [event characters];
	unsigned index = [chars intValue];
	[self useColorAtIndex:index];
}

- (IBAction)useMostRecentColors:sender;
{
	mode = PXPaletteModeRecent;
	[paletteView setPalette:recentPalette];
}

- (IBAction)useMostFrequentColors:sender;
{
	mode = PXPaletteModeFrequency;
	[paletteView setPalette:frequencyPalette];
}

- (IBAction)useColorListColors:sender;
{
	mode = PXPaletteModeColorList;
}

@end

