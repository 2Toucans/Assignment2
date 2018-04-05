//
//  Collisions.m
//  Assignment2
//
//  Created by Colt King on 2018-04-04.
//  Copyright © 2018 2Toucans. All rights reserved.
//

#import "Collisions.h"
#include <Box2D/Box2D.h>

@implementation Collisions
{
    b2World* world;
    b2Body* horseBody;
}

- (id)init
{
    if((self=[super init])){
        [self createWorld];
        
    }
    return self;
}

- (void)update:(float)et
{
    const float ts = 1.0f/60.0f;
    
    while(et >= ts)
    {
        world->Step(ts, 10, 10);
        et -= ts;
    }
    
    if(et > 0.0f)
        world->Step(et, 10, 10);
}

- (void)addHorse:(float)xPos y:(float)yPos w:(float)width h:(float)height
{
    //define body and set parameters
    b2BodyDef horseDef;
    horseDef.type = b2_dynamicBody;
    horseDef.position.Set(xPos, yPos);
    
    horseBody = world->CreateBody(&horseDef);
    
    //define floor fixture and needed parameters
    b2PolygonShape box;
    box.SetAsBox(width, height);
    
    //define fixture
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &box;
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.3f;
    fixtureDef.restitution = 0.6f;
    
    horseBody->CreateFixture(&fixtureDef);
}

- (void)addBody:(float)xPos y:(float)yPos w:(float)width h:(float)height
{
    //define body and set parameters
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position.Set(xPos, yPos);
    
    b2Body* body = world->CreateBody(&bodyDef);
    
    //define floor fixture and needed parameters
    b2PolygonShape box;
    box.SetAsBox(width, height);
    
    //define fixture
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &box;
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.3f;
    fixtureDef.restitution = 0.6f;
    
    body->CreateFixture(&fixtureDef);
}

- (GLKVector2)horsePos
{
    GLKVector2 pos = GLKVector2Make(horseBody->GetPosition().x, horseBody->GetPosition().y);
    return pos;
}

- (void)pushHorse:(float)xV y:(float)yV
{
    const b2Vec2 pushVec = b2Vec2(xV, yV);
    
    horseBody->ApplyForceToCenter(pushVec, true);
}

- (void)createWorld
{
    b2Vec2 gravity = b2Vec2(0.0f, 0.0f);
    
    world = (b2World*)malloc(sizeof(b2World));
    world = new b2World(gravity);
}

@end
