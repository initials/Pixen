//
//  PXIconExporter.h
//  Pixen
//
//  Created by Andy Matuschak on 6/16/05.
//  Copyright 2005 Pixen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PXCanvas;
@interface PXIconExporter : NSObject
{
  @private
	PXCanvas *canvas;
	NSMutableData *iconData;
}

- iconDataForCanvas:(PXCanvas *)aCanvas;

- (void)writeIconFileHeader;
- (void)writeImage;

- (void)writeImageData;


@end
