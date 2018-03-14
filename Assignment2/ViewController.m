//
//  ViewController.m
//  Assignment2
//
//  Created by Colt King on 2018-02-28.
//  Copyright © 2018 2Toucans. All rights reserved.
//

#import "ViewController.h"
#import "Renderer.h"

@interface ViewController ()

@end

@implementation ViewController
{
    CGPoint swipePos;
    Game* game;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GLKView* view = (GLKView *) self.view;
    [Renderer setup:view];
    
    game = [[Game alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [Renderer close];
}
- (IBAction)panGesture:(UIPanGestureRecognizer *)sender
{
    if(sender.state == UIGestureRecognizerStateBegan)
    {
        swipePos = CGPointZero;
    }
    
    CGPoint point = [sender translationInView:self.view];
    //translate point-swipe
    swipePos = point;
    
}
- (IBAction)doubleTap:(id)sender
{
    //trigger console show
    //tell game to update map
}

- (void) update
{
    [game update];
}

- (void)glkView:(GLKView*)view drawInRect:(CGRect)rect
{
    [Renderer draw:rect];
}

@end
