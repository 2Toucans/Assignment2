//
//  Game.mm
//  Assignment2
//
//  Created by Colt King on 2018-03-11.
//  Copyright © 2018 2Toucans. All rights reserved.
//

#import "Game.h"
#include "maze.h"
#include <chrono>

struct CPPMaze {
    Maze maze;
};

@implementation Game
{
    //Renderer* renderer;
    std::chrono::time_point<std::chrono::steady_clock> lastTime;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        cppMaze = new CPPMaze;
        
        //send renderer positions of all the tiles and walls
    }
    return self;
}

- (void)update
{
    auto currentTime = std::chrono::steady_clock::now();
    auto timeElapsed = std::chrono::duration_cast<std::chrono::milliseconds>(currentTime-lastTime).count();
    lastTime = currentTime;
    //deal with spinning cube rotation
    
    
}

//USE MAZE LIKE THIS:
//cppMaze->maze.method();

/*float cubeVerts[] =
 {
 -0.4f, -0.4f, -0.05f,
 -0.4f, -0.4f,  0.05f,
  0.4f, -0.4f,  0.05f,
  0.4f, -0.4f, -0.05f,
 -0.4f,  0.4f, -0.05f,
 -0.4f,  0.4f,  0.05f,
  0.4f,  0.4f,  0.05f,
  0.4f,  0.4f, -0.05f,
 -0.4f, -0.4f, -0.05f,
 -0.4f,  0.4f, -0.05f,
  0.4f,  0.4f, -0.05f,
  0.4f, -0.4f, -0.05f,
 -0.4f, -0.4f,  0.05f,
 -0.4f,  0.4f,  0.05f,
  0.4f,  0.4f,  0.05f,
  0.4f, -0.4f,  0.05f,
 -0.4f, -0.4f, -0.05f,
 -0.4f, -0.4f,  0.05f,
 -0.4f,  0.4f,  0.05f,
 -0.4f,  0.4f, -0.05f,
  0.4f, -0.4f, -0.05f,
  0.4f, -0.4f,  0.05f,
  0.4f,  0.4f,  0.05f,
  0.4f,  0.4f, -0.05f,
 };*/

@end
