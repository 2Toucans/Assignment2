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

Model* cube;

GLKMatrix4 mvpMatrix;
GLKMatrix3 normalMatrix;
GLKMatrix4 perspectiveMatrix;

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
    
    cube = [[Model alloc] init];
    float* vertices;
    float* normals;
    float* texCoords;
    int* indices;
    [cube setNumIndices:(glesRenderer.GenCube(1.0f, &vertices, &normals, &texCoords, &indices))];
    [cube setVertices:vertices];
    [cube setNormals:normals];
    [cube setTexCoords:texCoords];
    [cube setIndices:indices];
    [cube setRotation:GLKMatrix4Identity];
    cube.x = 0;
    cube.y = 0;
    cube.z = -5;
    cube.rotation = GLKMatrix4Identity;
}

+ (void)close {
    glDeleteProgram(program);
}

+ (void)draw: (CGRect)drawRect {
    mvpMatrix = GLKMatrix4Translate(GLKMatrix4Identity, cube.x, cube.y, cube.z);
    mvpMatrix = GLKMatrix4Multiply(mvpMatrix, cube.rotation);
    normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(mvpMatrix), NULL);
    
    float aspect = (float)view.drawableWidth / (float)view.drawableHeight;
    perspectiveMatrix = GLKMatrix4MakePerspective(60.0f * M_PI / 180.0f, aspect, 1.0f, 20.0f);
    
    mvpMatrix = GLKMatrix4Multiply(perspectiveMatrix, mvpMatrix);

    glUniformMatrix4fv(uniforms[UNIFORM_MVP_MATRIX], 1, FALSE, (const float *)mvpMatrix.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, normalMatrix.m);
    glUniform1i(uniforms[UNIFORM_PASS], false);
    glUniform1i(uniforms[UNIFORM_SHADEINFRAG], true);
    
    glViewport(0, 0, (int)view.drawableWidth, (int)view.drawableHeight);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glUseProgram(program);
    
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GLfloat), cube.vertices);
    glEnableVertexAttribArray(0);
    glVertexAttrib4f(1, 0.1f, 0.97f, 0.3f, 1.0f);
    glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GLfloat), cube.normals);
    glEnableVertexAttribArray(2);
    glUniformMatrix4fv(uniforms[UNIFORM_MVP_MATRIX], 1, FALSE, (const float *)mvpMatrix.m);
    glDrawElements(GL_TRIANGLES, cube.numIndices, GL_UNSIGNED_INT, cube.indices);
}

+ (void)addModel: (Model*)model {
    
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
