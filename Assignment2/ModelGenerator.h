//
//  ModelGenerator.h
//  Assignment2
//
//  Created by Colt King on 2018-03-14.
//  Copyright © 2018 2Toucans. All rights reserved.
//

#ifndef ModelGenerator_h
#define ModelGenerator_h

#import <Foundation/Foundation.h>

@interface ModelGenerator : NSObject

+ (float*)vertWallVerts;

+ (float*)horizWallVerts;

+ (float*)tileVerts;

+ (float*)postVerts;

+ (float*)cubeVerts;

+ (float*)cubeNormals;

+ (float*)cubeTex;

+ (int*)cubeInds;

@end

#endif /* ModelGenerator_h */
