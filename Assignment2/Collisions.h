//
//  Collisions.h
//  Assignment2
//
//  Created by Colt King on 2018-04-04.
//  Copyright © 2018 2Toucans. All rights reserved.
//

#ifndef Collisions_h
#define Collisions_h
#import <Foundation/Foundation.h>
#include <Box2D/Box2D.h>

@interface Collisions : NSObject
{
    
}

- (void)update:(float)et;

- (void)addHorse:(float)xPos y:(float)yPos w:(float)width h:(float)height;

- (void)addBody:(float)xPos y:(float)yPos w:(float)width h:(float)height;

- (b2Vec2)horsePos;

@end

#endif /* Collisions_h */
