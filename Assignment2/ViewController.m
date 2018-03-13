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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    GLKView* view = (GLKView *) self.view;
    [Renderer setup:view];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [Renderer close];
}

- (void)glkView:(GLKView*)view drawInRect:(CGRect)rect {
    [Renderer draw:rect];
}

@end
