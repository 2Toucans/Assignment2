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

enum Textures
{
    both, none, leftRight, rightLeft
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

//make arrays to carry vertical and horizontal walls
//make function to check walls on either side, return texture enum and
//use switch instead of if statement
- (void)setTexture
{
    for(float offX = 0; offX < cppMaze->maze.cols; offX += 1)
    {
        for(float offY = 0; offY < cppMaze->maze.rows; offY += 1)
        {
            //posts
            //addModel(post, offX, offY, 0, texP)
            
            //tiles
            //addModel(tile, offX+0.5, offY+0.5, -1, texT)
            
            //vertical walls
            //if(vertWalls[offX][offY])
                //Textures wallTex = whichTexture(true, offX, offY)
                //addModel(vWall, offX, offY+0.5, 0, wallTex)
            
            //horizontal walls
            //if(horizWalls[offX][offY])
                //wallTex = whichTexture(false, offX, offY)
                //addModel(hWall, offX+0.5, offY, 0, wallTex)
        }
        
        //missing row of posts
        //addModel(post, offX, cppMaze->maze.rows, 0, texP)
        
        //missing row of horizontal walls
        //if(horizWalls[offX][cppMaze->maze.rows])
            //Textures wallTex = whichTexture(false, offX, cppMaze->maze.rows)
            //addModel(hWall, offX, cppMaze->maze.rows, 0, wallTex)
    }
    
    for(int offY = 0; offY < cppMaze->maze.rows; offY++)
    {
        //missing column of posts
        //addModel(post, cppMaze->maze.cols, offY, 0, texP)
        
        //missing column of vertical walls
        //if(vertWalls[cppMaze->maze.cols][offY])
            //Textures wallTex = whichTexture(true, cppMaze->maze.cols, offY)
            //addModel(vWall, cppMaze->maze.cols, offY, 0, wallTex)
    }
    
    //missing bottom right post
    //addModel(post, cppMaze->maze.cols, cppMaze->maze.rows, 0, texP)
}

//Determines which textures the wall should have based on surrounding
//walls and its orientation
- (Textures)whichTexture:(bool)vertical x:(float)xPos y:(float)yPos
{
    return leftRight;
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
