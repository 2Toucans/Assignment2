//
//  Renderer.m
//  Assignment2
//
//  Created by Aaron F on 2018-03-12.
//  Copyright © 2018 2Toucans. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#include <chrono>
#include "GLESRenderer.hpp"
#include "Renderer.h"

enum {
    UNIFORM_MVP_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    UNIFORM_PASS,
    UNIFORM_SHADEINFRAG,
    NUM_UNIFORMS
};

enum {
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBS
};

GLint uniforms[NUM_UNIFORMS];
GLKView* view;
GLESRenderer glesRenderer;
GLuint program;
std::chrono::time_point<std::chrono::steady_clock> prevFrameTime;

NSMutableDictionary* models;
NSMutableArray* textures;

GLKMatrix3 normalMatrix;
GLKMatrix4 perspectiveMatrix;
GLKMatrix4 cameraMatrix;

float bgColor[] = {0.2f, 0.7f, 0.95f, 0.0f};

@interface Renderer ()
+ (bool)setupShaders;
@end

@implementation Renderer

+ (void)setup: (GLKView*)v {
    v.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!v.context) {
        NSLog(@"Failed to create ES 3.0 context");
        NSException *contextFailedException = [NSException
                                               exceptionWithName:@"GLESFailureException"
                                               reason:@"Failed to create context"
                                               userInfo: nil];
        @throw contextFailedException;
    }
    
    v.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    view = v;
    
    [EAGLContext setCurrentContext:view.context];
    
    if (![self setupShaders]) {
        NSLog(@"Failed to initialize shaders");
        NSException *contextFailedException = [NSException
                                               exceptionWithName:@"GLESFailureException"
                                               reason:@"Failed to initialize shaders"
                                               userInfo: nil];
        @throw contextFailedException;
    }
    
    glClearColor(bgColor[0], bgColor[1], bgColor[2], bgColor[3]);
    glEnable(GL_DEPTH_TEST);
    prevFrameTime = std::chrono::steady_clock::now();
    
    Model* cube;
    cube = [[Model alloc] init];
    models = [[NSMutableDictionary alloc] init];
    textures = [[NSMutableArray alloc] init];
    cameraMatrix = GLKMatrix4Identity;
    
    float* vertices;
    float* normals;
    float* texCoords;
    int* indices;
    [cube setNumIndices:(glesRenderer.GenCube(1.0f, &vertices, &normals, &texCoords, &indices))];
    [cube setVertices:vertices];
    [cube setNormals:normals];
    [cube setTexCoords:texCoords];
    [cube setIndices:indices];
    [cube setPosition:GLKMatrix4Translate(GLKMatrix4Identity, 0, 0, 0)];
    
    [self addModel:cube texture:@"test"];
    
    cube = [[Model alloc] init];
    [cube setNumIndices:(glesRenderer.GenCube(1.0f, &vertices, &normals, &texCoords, &indices))];
    [cube setVertices:vertices];
    [cube setNormals:normals];
    [cube setTexCoords:texCoords];
    [cube setIndices:indices];
    [cube setPosition:GLKMatrix4Translate(GLKMatrix4Identity, 0, 1.2, 0)];
    
    [self addModel:cube texture:@"test"];
    
    [Renderer moveCamera:0 y:1 z:4];
    [Renderer rotateCamera:0.24 x:1 y:0 z:0];
    
}

+ (void)close {
    glDeleteProgram(program);
}

+ (void)draw: (CGRect)drawRect {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [models enumerateKeysAndObjectsUsingBlock:^(NSString* texture, NSMutableArray* models, BOOL* stop) {
        for (int i = 0; i < [models count]; i++) {
            Model* m = models[i];
            
            GLKMatrix4 mvpMatrix = m.position;
            normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(mvpMatrix), NULL);
            
            float aspect = (float)view.drawableWidth / (float)view.drawableHeight;
            perspectiveMatrix = GLKMatrix4MakePerspective(60.0f * M_PI / 180.0f, aspect, 1.0f, 20.0f);
            
            mvpMatrix = GLKMatrix4Multiply(GLKMatrix4Invert(cameraMatrix, FALSE), mvpMatrix);
            mvpMatrix = GLKMatrix4Multiply(perspectiveMatrix, mvpMatrix);

            glUniformMatrix4fv(uniforms[UNIFORM_MVP_MATRIX], 1, FALSE, (const float *)mvpMatrix.m);
            glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, normalMatrix.m);
            glUniform1i(uniforms[UNIFORM_PASS], false);
            glUniform1i(uniforms[UNIFORM_SHADEINFRAG], true);
            
            glViewport(0, 0, (int)view.drawableWidth, (int)view.drawableHeight);
            glUseProgram(program);
            
            glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GLfloat), m.vertices);
            glEnableVertexAttribArray(0);
            glVertexAttrib4f(1, 0.1f, 0.97f, 0.3f, 1.0f);
            glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GLfloat), m.normals);
            glEnableVertexAttribArray(2);
            glUniformMatrix4fv(uniforms[UNIFORM_MVP_MATRIX], 1, FALSE, (const float *)mvpMatrix.m);
            glDrawElements(GL_TRIANGLES, m.numIndices, GL_UNSIGNED_INT, m.indices);
        }
    }];
}

+ (void)addModel: (Model*)model texture:(NSString*)texture {
    if ([models objectForKey:texture] == nil) {
        [models setObject:[[NSMutableArray alloc] init] forKey:texture];
    }
    [models[texture] addObject:model];
}

+ (void)moveCamera:(float)x y:(float)y z:(float)z {
    cameraMatrix = GLKMatrix4Multiply(GLKMatrix4Translate(GLKMatrix4Identity, x, y, z), cameraMatrix);
}

+ (void)moveCameraRelative:(float)x y:(float)y z:(float)z {
    cameraMatrix = GLKMatrix4Translate(cameraMatrix, x, y, z);
}

+ (void)rotateCamera:(float)angle x:(float)x y:(float)y z:(float)z {
    cameraMatrix = GLKMatrix4Rotate(cameraMatrix, -angle, x, y, z);
}

+ (bool)setupShaders {
    char *vShaderStr = glesRenderer.LoadShaderFile([[[NSBundle mainBundle] pathForResource: [[NSString stringWithUTF8String:"Shader.vsh"] stringByDeletingPathExtension] ofType:[[NSString stringWithUTF8String:"Shader.vsh"] pathExtension]] cStringUsingEncoding:1]);
    char *fShaderStr = glesRenderer.LoadShaderFile([[[NSBundle mainBundle] pathForResource: [[NSString stringWithUTF8String:"Shader.fsh"] stringByDeletingPathExtension] ofType:[[NSString stringWithUTF8String:"Shader.fsh"] pathExtension]] cStringUsingEncoding:1]);
    program = glesRenderer.LoadProgram(vShaderStr, fShaderStr);
    if (program == 0) {
        return false;
    }
    
    uniforms[UNIFORM_MVP_MATRIX] = glGetUniformLocation(program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(program, "normalMatrix");
    
    return true;
}

@end
