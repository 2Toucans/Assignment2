//
//  ModelReader.m
//  Assignment2
//
//  Created by Aaron Freytag on 2018-04-04.
//  Copyright © 2018 2Toucans. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "ModelReader.h"

@implementation ModelReader


+ (Model*) loadModel: (NSString*)res {
    NSString* path = [[NSBundle mainBundle] pathForResource: res ofType: @"txt"];
    NSString* file = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    
    NSArray* lines = [file componentsSeparatedByString:@"\n"];
    for (NSString* s in lines) {
        
    }
}

@end
