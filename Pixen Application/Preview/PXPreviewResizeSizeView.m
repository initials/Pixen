//
//  PXPreviewResizeSizeView.m
//  Pixen
//

#import "PXPreviewResizeSizeView.h"


@implementation PXPreviewResizeSizeView

- (id) initWithFrame:(NSRect)frame
{
	if ( ! ( self = [super initWithFrame:frame]) ) 
		return nil;
	
	shadow = [[NSShadow alloc] init];
	[shadow setShadowBlurRadius:1];
	[shadow setShadowOffset:NSMakeSize(0, 0)];
	[shadow setShadowColor:[NSColor blackColor]];
	[self updateScale:0];
	return self;
}

- (void)dealloc
{
	[shadow release];
	[super dealloc];
}

- (BOOL)updateScale:(float)scale
{
	if (scale > 100000) {
		return NO;
	}
	[scaleString release];
	scaleString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d%%", (int)(scale * 100)] attributes:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSFont fontWithName:@"Verdana" size:20], NSFontAttributeName,
		[NSColor blackColor], NSForegroundColorAttributeName,
		//shadow, NSShadowAttributeName,
		nil]];
	[self setNeedsDisplay:YES];
	return YES;
}

- (void)drawRect:(NSRect)rect
{
//dontreadthisoritwillhurtyourhead, evidently.
	[[NSColor clearColor] set];
	NSRectFill([self frame]);
	NSRect frame = [self frame];
	NSBezierPath *background = [NSBezierPath bezierPath];
	NSPoint stringPoint = frame.origin;
	float x = NSMinX(frame), y = NSMinY(frame), width = NSWidth(frame), height = NSHeight(frame), maxX = NSMaxX(frame);
	if (height >= width) {
		[background appendBezierPathWithOvalInRect:frame];
	} else {
		NSRect leftSide = NSMakeRect(x, y, height, height);
		NSRect rightSide = NSMakeRect(maxX - height, y, height, height);
		NSRect middle = NSMakeRect(x + (height / 2.0f), y, width - height, height);
		NSRect topLeftCorner = NSMakeRect(x, y+(height/2), height/2, height/2);
		
		[background appendBezierPathWithOvalInRect:leftSide];
		[background appendBezierPathWithOvalInRect:rightSide];
		[background appendBezierPathWithRect:middle];
		
		[background appendBezierPathWithRect:topLeftCorner];
	}
	stringPoint.x += (width - [scaleString size].width) / 2;
	stringPoint.y += (height - [scaleString size].height) / 2 + [scaleString size].height / 9;
	[[NSColor whiteColor] set];
	[background fill];
	[scaleString drawAtPoint:stringPoint];
}

- (NSSize)scaleStringSize
{
	NSSize size = [scaleString size];
	return NSMakeSize(size.width * 1.3, size.height);
}

@end
