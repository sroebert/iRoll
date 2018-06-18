#import <Foundation/Foundation.h>
#import "Widget.h"

/**
 * The main function for the statistics calculator.
 */
int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	// Create an array for each widget potential and booleans specifying whether 
	// the widget is valid
	int maxHashNr = pow(2, 19);
	int widgetCount = 0;
	
	BOOL widgetValidation[maxHashNr];
	float widgetPotentials[maxHashNr];
	
	for (int i = 0; i < maxHashNr; i++) {
		// Validate each widget
		if (widgetValidation[i] = [Widget isValidHash:i]) {
			widgetPotentials[i] = -1;
			widgetCount++;
		}
		else {
			widgetPotentials[i] = -2;
		}
	}
	
	// Create a widget instance
	Widget *widget = [[Widget alloc] init];
	
	// Continue until all widget potentials have been calculated
	int counter = 0;
	while (counter < widgetCount)
	{
		BOOL changed = NO;
		for (int i = maxHashNr - 1; i >= 0; i--) {
			// Continue if the widget potential has been calculated or if the widget is invalid
			if (!widgetValidation[i] || widgetPotentials[i] > -1) {
				continue;
			}
			
			[widget setHash:i];
			if ([widget calculatePotential:widgetPotentials]) {
				widgetPotentials[i] = widget.potential;
				changed = YES;
				
				// Log updates
				counter++;
				if (counter % 500 == 0) {
					NSLog(@"%d/%d", counter, widgetCount);
				}
			}
		}
		
		if (!changed) {
			break;
		}
	}
	NSLog(@"%d/%d", counter, widgetCount);
	
	// Save the potentials and widgetdata to disk.
	NSData *potentialData = [[NSData alloc] initWithBytesNoCopy:widgetPotentials 
		length:sizeof(float)*maxHashNr freeWhenDone:NO];
	[potentialData writeToFile:@"potentials.bin" atomically:NO];
	[potentialData release];
	
	[widget saveWidgetDataToFile:@"widgetdata.bin"];
	[widget release];
	
    [pool drain];
    return 0;
}
