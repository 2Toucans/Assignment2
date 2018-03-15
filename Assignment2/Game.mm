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

enum Texture
{
    texWallBoth, texWallNone, texWallLeft, texWallRight, texPost, texTile
};

enum ModelType
{
    post, tile, vWallL, vWallR, hWallT, hWallB
};

@implementation Game
{
    std::chrono::time_point<std::chrono::steady_clock> lastTime;
    
    bool **vertWalls, **horizWalls;
    float yRotate;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        cppMaze = new CPPMaze;
        
        rows = 4;
        cols = 4;
        
        [self populateWalls];
        
        [self setModels];
    }
    return self;
}

- (void)update
{
    auto currentTime = std::chrono::steady_clock::now();
    auto timeElapsed = std::chrono::duration_cast<std::chrono::milliseconds>(currentTime-lastTime).count();
    lastTime = currentTime;
    //deal with spinning cube rotation
    
    //deal with player movement
}

- (void)move:(float)x y:(float)y
{
    [Renderer moveCameraRelative:x/100 y:0 z:y/100];
}

- (void)rotate:(float)y
{
    [Renderer rotateCamera:y/100 x:0 y:1 z:0];
}

- (void)reset
{
    //[Renderer setPosition:0 y:0 z:0] something like this
}

- (void)populateWalls
{
    vertWalls = (bool**)calloc(cppMaze->maze.cols+1, sizeof(bool*));
    for (int i = 0; i < cppMaze->maze.cols; i++) {
        vertWalls[i] = (bool*)calloc(cppMaze->maze.rows, sizeof(bool));
        for(int j = 0; j < cppMaze->maze.rows; j++) {
            //check for walls and set true if wall
            vertWalls[i][j] = cppMaze->maze.GetCell(i, j).westWallPresent;
        }
    }
    //do last vert column
    for(int j = 0; j < cppMaze->maze.rows; j++)
    {
        vertWalls[cppMaze->maze.cols][j] = cppMaze->maze.GetCell(cppMaze->maze.cols, j).eastWallPresent;
    }
    
    horizWalls = (bool**)calloc(cppMaze->maze.cols, sizeof(bool*));
    for (int i = 0; i < cppMaze->maze.cols; i++) {
        horizWalls[i] = (bool*)calloc(cppMaze->maze.rows+1, sizeof(bool));
        for(int j = 0; j < cppMaze->maze.rows; j++) {
            //check for walls and set true if wall
            horizWalls[i][j] = cppMaze->maze.GetCell(i, j).northWallPresent;
        }
        //do last horiz column
        horizWalls[i][cppMaze->maze.rows] = cppMaze->maze.GetCell(i, cppMaze->maze.rows).southWallPresent;
    }
}

//Determines the parameters for the posts, tiles, and walls and sends them to the renderer
- (void)setModels
{
    for(float offX = 0; offX < cppMaze->maze.cols; offX += 1)
    {
        for(float offY = 0; offY < cppMaze->maze.rows; offY += 1)
        {
            //posts
            [self makeModel:post x:offX y:offY z:0 t:texPost];
            
            //tiles
            [self makeModel:tile x:offX+0.5 y:offY+0.5 z:-1 t:texTile];
            
            //vertical walls
            if(vertWalls[(int)offX][(int)offY])
            {
                Texture wallTex = [self whichTexture:true x:(int)offX y:(int)offY];
                [self makeModel:vWallL x:offX-0.025 y:offY+0.5 z:0 t:wallTex];
                
                if(wallTex == texWallLeft)
                    wallTex = texWallRight;
                else if(wallTex == texWallRight)
                    wallTex = texWallLeft;
                
                [self makeModel:vWallR x:offX+0.025 y:offY+0.5 z:0 t:wallTex];
            }
            
            //horizontal walls
            if(horizWalls[(int)offX][(int)offY])
            {
                Texture wallTex = [self whichTexture:false x:(int)offX y:(int)offY];
                [self makeModel:hWallT x:offX+0.5 y:offY-0.025 z:0 t:wallTex];
                
                if(wallTex == texWallLeft)
                    wallTex = texWallRight;
                else if(wallTex == texWallRight)
                    wallTex = texWallLeft;
                
                [self makeModel:hWallB x:offX+0.5 y:offY+0.025 z:0 t:wallTex];
            }
        }
        
        //missing row of posts
        [self makeModel:post x:offX y:cppMaze->maze.rows z:0 t:texPost];
        
        //missing row of horizontal walls
        if(horizWalls[(int)offX][cppMaze->maze.rows])
        {
            Texture wallTex = [self whichTexture:false x:(int)offX y:cppMaze->maze.rows];
            [self makeModel:hWallT x:offX y:cppMaze->maze.rows-0.025 z:0 t:wallTex];
            
            if(wallTex == texWallLeft)
                wallTex = texWallRight;
            else if(wallTex == texWallRight)
                wallTex = texWallLeft;
            
            [self makeModel:hWallB x:offX y:cppMaze->maze.rows+0.025 z:0 t:wallTex];
        }
    }
    
    for(int offY = 0; offY < cppMaze->maze.rows; offY++)
    {
        //missing column of posts
        [self makeModel:post x:cppMaze->maze.cols y:offY z:0 t:texPost];
        
        //missing column of vertical walls
        if(vertWalls[cppMaze->maze.cols][(int)offY])
        {
            Texture wallTex = [self whichTexture:true x:cppMaze->maze.cols y:(int)offY];
            [self makeModel:vWallL x:cppMaze->maze.cols-0.025 y:offY z:0 t:wallTex];
            
            if(wallTex == texWallLeft)
                wallTex = texWallRight;
            else if(wallTex == texWallRight)
                wallTex = texWallLeft;
            
            [self makeModel:vWallR x:cppMaze->maze.cols+0.025 y:offY z:0 t:wallTex];
        }
    }
    
    //missing bottom right post
    [self makeModel:post x:cppMaze->maze.cols y:cppMaze->maze.rows z:0 t:texPost];
}

//Formats the model then sends the pieces to the corresponding arrays in the renderer
- (void)makeModel:(ModelType)type x:(float)xPos y:(float)yPos z:(float)zPos t:(Texture)tex
{
    
}

//Determines which textures the wall should have based on surrounding
//walls and its orientation
- (Texture)whichTexture:(bool)vertical x:(int)xPos y:(int)yPos
{
    Texture tex;
    if(vertical)
    {
        //vertWalls[xPos][yPos]
        //if yPos-1 != null && yPos
    }
    else
    {
        
    }
    
    return texWallLeft;
}

//USE MAZE LIKE THIS:
//cppMaze->maze.method();

/*float cubeVerts[] =
 {
 -0.4f, -0.4f, -0.025f,
 -0.4f, -0.4f,  0.025f,
  0.4f, -0.4f,  0.025f,
  0.4f, -0.4f, -0.025f,
 -0.4f,  0.4f, -0.025f,
 -0.4f,  0.4f,  0.025f,
  0.4f,  0.4f,  0.025f,
  0.4f,  0.4f, -0.025f,
 -0.4f, -0.4f, -0.025f,
 -0.4f,  0.4f, -0.025f,
  0.4f,  0.4f, -0.025f,
  0.4f, -0.4f, -0.025f,
 -0.4f, -0.4f,  0.025f,
 -0.4f,  0.4f,  0.025f,
  0.4f,  0.4f,  0.025f,
  0.4f, -0.4f,  0.025f,
 -0.4f, -0.4f, -0.025f,
 -0.4f, -0.4f,  0.025f,
 -0.4f,  0.4f,  0.025f,
 -0.4f,  0.4f, -0.025f,
  0.4f, -0.4f, -0.025f,
  0.4f, -0.4f,  0.025f,
  0.4f,  0.4f,  0.025f,
  0.4f,  0.4f, -0.025f,
 };*/

@end
