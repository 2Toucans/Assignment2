//
//  Game.mm
//  Assignment2
//
//  Created by Colt King on 2018-03-11.
//  Copyright © 2018 2Toucans. All rights reserved.
//

#import "Game.h"
#include "maze.h"

struct CPPMaze {
    Maze maze;
};

@implementation Game

- (id)init
{
    self = [super init];
    if (self)
    {
        cppMaze = new CPPMaze;
    }
    return self;
}

//USE MAZE LIKE THIS:
//cppMaze->maze.method();

@end
