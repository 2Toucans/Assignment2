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

struct CPPMaze;

@interface Game : NSObject
{
    @private
    struct CPPMaze* cppMaze;
}

- (void)update;

@end

#endif /* Game_h */
