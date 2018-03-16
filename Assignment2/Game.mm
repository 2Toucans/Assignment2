//
//  Game.mm
//  Assignment2
//
//  Created by Colt King on 2018-03-11.
//  Copyright © 2018 2Toucans. All rights reserved.
//

#import "Game.h"
#include <chrono>

static bool vertWalls[4][5] =
{
    {true, true, false, false, true},
    {true, true, true, true, true},
    {true, false, true, true, true},
    {true, false, false, true, true}
};

static bool horizWalls[5][4] =
{
    {false, true, true, true},
    {false, false, true, false},
    {false, false, false, false},
    {false, true, false, false},
    {true, true, true, false}
};

enum Texture
{
    texWallBoth, texWallNone, texWallLeft, texWallRight, texPost, texTile, texCube
};

enum ModelType
{
    post, tile, vWall, hWall, cube
};

@implementation Game
{
    std::chrono::time_point<std::chrono::steady_clock> lastTime;
    
    float yRotate;
    Model* spinCube;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        rows = 4;
        cols = 4;

        [self setModels];
        
        [self makeCube:1 y:1 z:0 t:texCube];
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

//Determines the parameters for the posts, tiles, and walls and sends them to the renderer
- (void)setModels
{
    for(float offX = 0; offX < cols; offX += 1)
    {
        for(float offY = 0; offY < rows; offY += 1)
        {
            //posts
            [self makeModel:post x:offX y:offY z:0 t:texPost];
            
            //tiles
            [self makeModel:tile x:offX+0.5 y:offY+0.5 z:-1 t:texTile];
            
            //vertical walls
            if(vertWalls[(int)offX][(int)offY])
            {
                Texture wallTex = [self whichTexture:true x:(int)offX y:(int)offY];
                [self makeModel:vWall x:offX-0.025 y:offY+0.5 z:0 t:wallTex];
                
                if(wallTex == texWallLeft)
                    wallTex = texWallRight;
                else if(wallTex == texWallRight)
                    wallTex = texWallLeft;
                
                [self makeModel:vWall x:offX+0.025 y:offY+0.5 z:0 t:wallTex];
            }
            
            //horizontal walls
            if(horizWalls[(int)offX][(int)offY])
            {
                Texture wallTex = [self whichTexture:false x:(int)offX y:(int)offY];
                [self makeModel:hWall x:offX+0.5 y:offY-0.025 z:0 t:wallTex];
                
                if(wallTex == texWallLeft)
                    wallTex = texWallRight;
                else if(wallTex == texWallRight)
                    wallTex = texWallLeft;
                
                [self makeModel:hWall x:offX+0.5 y:offY+0.025 z:0 t:wallTex];
            }
        }
        
        //missing row of posts
        [self makeModel:post x:offX y:rows z:0 t:texPost];
        
        //missing row of horizontal walls
        if(horizWalls[(int)offX][rows])
        {
            Texture wallTex = [self whichTexture:false x:(int)offX y:rows];
            [self makeModel:hWall x:offX y:rows-0.025 z:0 t:wallTex];
            
            if(wallTex == texWallLeft)
                wallTex = texWallRight;
            else if(wallTex == texWallRight)
                wallTex = texWallLeft;
            
            [self makeModel:hWall x:offX y:rows+0.025 z:0 t:wallTex];
        }
    }
    
    for(int offY = 0; offY < rows; offY++)
    {
        //missing column of posts
        [self makeModel:post x:cols y:offY z:0 t:texPost];
        
        //missing column of vertical walls
        if(vertWalls[cols][(int)offY])
        {
            Texture wallTex = [self whichTexture:true x:cols y:(int)offY];
            [self makeModel:vWall x:cols-0.025 y:offY z:0 t:wallTex];
            
            if(wallTex == texWallLeft)
                wallTex = texWallRight;
            else if(wallTex == texWallRight)
                wallTex = texWallLeft;
            
            [self makeModel:vWall x:cols+0.025 y:offY z:0 t:wallTex];
        }
    }
    
    //missing bottom right post
    [self makeModel:post x:cols y:rows z:0 t:texPost];
}

//Formats the model then sends the pieces to the corresponding arrays in the renderer
- (void)makeModel:(ModelType)type x:(float)xPos y:(float)yPos z:(float)zPos t:(Texture)tex
{
    NSString* fileName;
    Model* model = [[Model alloc] init];
    
    switch(tex)
    {
        case texWallBoth:
            fileName = @"color.jpg";
            break;
        case texWallNone:
            fileName = @"kching.jpg";
            break;
        case texWallLeft:
            fileName = @"beauty.jpg";
            break;
        case texWallRight:
            fileName = @"groovy.jpg";
            break;
        case texPost:
            fileName = @"crate.jpg";
            break;
        case texTile:
            fileName = @"tiger.jpg";
            break;
        case texCube:
            fileName = @"crate.jpg";
            break;
    }
    
    switch(type)
    {
        case post:
            [model setVertices:[ModelGenerator postVerts]];
            break;
        case tile:
            [model setVertices:[ModelGenerator tileVerts]];
            break;
        case vWall:
            [model setVertices:[ModelGenerator vertWallVerts]];
            break;
        case hWall:
            [model setVertices:[ModelGenerator horizWallVerts]];
            break;
        case cube:
            [model setVertices:[ModelGenerator cubeVerts]];
            break;
    }
    
    [model setNormals:[ModelGenerator cubeNormals]];
    [model setTexCoords:[ModelGenerator cubeTex]];
    [model setIndices:[ModelGenerator cubeInds]];
    [model setPosition:GLKMatrix4Translate(GLKMatrix4Identity, xPos, zPos, yPos)];
    
    [Renderer addModel:model texture:fileName];
}

//Determines which textures the wall should have based on surrounding
//walls and its orientation
- (Texture)whichTexture:(bool)vertical x:(int)x y:(int)y
{
    Texture tex;
    
    if(vertical)
    {
        if (x > 0 && vertWalls[x-1][y] && (x+1 > rows || !vertWalls[x+1][y]))
            tex = texWallLeft;
        else if(x < rows && vertWalls[x+1][y] && (x == 0 || !vertWalls[x-1][y]))
            tex = texWallRight;
        else if(x > 0 && x < rows && vertWalls[x-1][y] && vertWalls[x+1][y])
            tex = texWallBoth;
        else
            tex = texWallNone;
    }
    else //horizontal
    {
        if (y > 0 && horizWalls[x][y-1] && (y+1 > cols || !horizWalls[x][y+1]))
            tex = texWallLeft;
        else if(y < cols && horizWalls[x][y+1] && (y == 0 || !horizWalls[x][y-1]))
            tex = texWallRight;
        else if(y > 0 && y < cols && horizWalls[x][y-1] && horizWalls[x][y+1])
            tex = texWallBoth;
        else
            tex = texWallNone;
    }
    
    return tex;
}

//Makes the spinning cube and stores it
- (void)makeCube:(float)xPos y:(float)yPos z:(float)zPos t:(Texture)tex
{
    NSString* fileName = @"crate.jpg";
    spinCube = [[Model alloc] init];

    [spinCube setVertices:[ModelGenerator cubeVerts]];
    [spinCube setNormals:[ModelGenerator cubeNormals]];
    [spinCube setTexCoords:[ModelGenerator cubeTex]];
    [spinCube setIndices:[ModelGenerator cubeInds]];
    [spinCube setPosition:GLKMatrix4Translate(GLKMatrix4Identity, xPos, zPos, yPos)];
    
    [Renderer addModel:spinCube texture:fileName];
}

@end
