//
//  ViewController.m
//  Assignment2
//
//  Created by Colt King on 2018-02-28.
//  Copyright © 2018 2Toucans. All rights reserved.
//

#import "ViewController.h"
#import "Renderer.h"
#import "EnvironmentController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *fogSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *dayNightSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *spotlightSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *fogStyleSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *controlSwitch;

@end

@implementation ViewController
{
    CGPoint swipePos, rotatePos;
    Game* game;
    EnvironmentController* ec;
}

- (IBAction)fogToggled:(id)sender {
    [ec toggleFog];
}

- (IBAction)dayToggled:(id)sender {
    [ec toggleDay];
}

- (IBAction)controlToggled:(id)sender {
}

- (IBAction)spotlightToggled:(id)sender {
    [ec toggleSpotLight];
}

- (IBAction)fogStyleToggled:(id)sender {
    [ec toggleFogType];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    GLKView* view = (GLKView *) self.view;
    [Renderer setup:view];
    
    game = [[Game alloc] init];
    ec = [[EnvironmentController alloc] init];
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
    
    float x = point.x - swipePos.x;
    float y = point.y - swipePos.y;
    
    [game move:x y:y];
    
    swipePos = point;
}

- (IBAction)rotateGesture:(UIPanGestureRecognizer *)sender
{
    if(sender.state == UIGestureRecognizerStateBegan)
    {
        rotatePos = CGPointZero;
    }
    
    CGPoint point = [sender translationInView:self.view];
    
    float x = point.x - rotatePos.x;
    
    [game rotate:x];
    
    rotatePos = point;
}

- (IBAction)tap:(id)sender
{
    // Used to call [game reset]
    // Now instead toggles the model moving autonomously
    
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
