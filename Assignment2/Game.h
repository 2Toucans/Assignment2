//
//  Game.h
//  Assignment2
//
//  Created by Colt King on 2018-03-11.
//  Copyright © 2018 2Toucans. All rights reserved.
//

#ifndef Game_h
#define Game_h

#import <Foundation/Foundation.h>
#include "Renderer.h"

struct CPPMaze;

@interface Game : NSObject
{
    @private
    struct CPPMaze* cppMaze;
    int rows, cols;
}

- (void)update;

- (void)move:(float)x y:(float)y;

- (void)rotate:(float)y;

@end

#endif /* Game_h */
