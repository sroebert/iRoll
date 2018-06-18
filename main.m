//
//  main.m
//  iRoll
//
//  Created by Steven Roebert on 15/02/2010.
//  Copyright Steven Roebert 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * iRoll main function, creating a UIApplicationMain instance
 */
int main(int argc, char *argv[]) {
    
	srand(time(NULL));
	
    @autoreleasepool {
        int retVal = UIApplicationMain(argc, argv, nil, nil);
        return retVal;
    }
}
