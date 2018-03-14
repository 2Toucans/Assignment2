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
    UNIFORM_MV_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    UNIFORM_PASS,
    UNIFORM_SHADEINFRAG,
    UNIFORM_TEXTURE,
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
NSMutableDictionary* textures;
NSMutableArray* lights;

GLKMatrix3 normalMatrix;
GLKMatrix4 perspectiveMatrix;
GLKMatrix4 cameraMatrix;
float bgColor[] = {0.2f, 0.7f, 0.95f, 0.0f};

@interface Renderer ()
+ (bool)setupShaders;
+ (void)loadTexture: (NSString*)fileName;
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
    textures = [[NSMutableDictionary alloc] init];
    lights = [[NSMutableArray alloc] init];
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
    
    [self addModel:cube texture:@"crate.jpg"];
    
    cube = [[Model alloc] init];
    [cube setNumIndices:(glesRenderer.GenCube(1.0f, &vertices, &normals, &texCoords, &indices))];
    [cube setVertices:vertices];
    [cube setNormals:normals];
    [cube setTexCoords:texCoords];
    [cube setIndices:indices];
    [cube setPosition:GLKMatrix4Translate(GLKMatrix4Identity, 0, 1.2, 0)];
    
    [self addModel:cube texture:@"badcrate.png"];
    
    cube = [[Model alloc] init];
    [cube setNumIndices:(glesRenderer.GenCube(1.0f, &vertices, &normals, &texCoords, &indices))];
    [cube setVertices:vertices];
    [cube setNormals:normals];
    [cube setTexCoords:texCoords];
    [cube setIndices:indices];
    [cube setPosition:GLKMatrix4Translate(GLKMatrix4Identity, 0, -1.2, 0)];
    
    [self addModel:cube texture:@"crate.jpg"];
    
    cube = [[Model alloc] init];
    [cube setNumIndices:(glesRenderer.GenCube(1.0f, &vertices, &normals, &texCoords, &indices))];
    [cube setVertices:vertices];
    [cube setNormals:normals];
    [cube setTexCoords:texCoords];
    [cube setIndices:indices];
    [cube setPosition:GLKMatrix4Translate(GLKMatrix4Identity, -1.2, 0, 0)];
    
    [self addModel:cube texture:@"badcrate.png"];
    
    cube = [[Model alloc] init];
    [cube setNumIndices:(glesRenderer.GenCube(1.0f, &vertices, &normals, &texCoords, &indices))];
    [cube setVertices:vertices];
    [cube setNormals:normals];
    [cube setTexCoords:texCoords];
    [cube setIndices:indices];
    [cube setPosition:GLKMatrix4Translate(GLKMatrix4Identity, 1.2, 0, 0)];
    
    [self addModel:cube texture:@"badcrate.png"];
    
    Light* light = (Light*)malloc(sizeof(Light));
    light->color = GLKVector3Make(1.0, 1.0, 0.8);
    light->direction = GLKVector3Make(0.0, -1.0, -0.3);
    light->type = DIRECTIONAL_LIGHT;
    
    [self addLight:light];
    
    light = (Light*)malloc(sizeof(Light));
    light->color = GLKVector3Make(0.0, 0.25, 0.7);
    light->direction = GLKVector3Make(-0.5, 0.3, -1.0);
    light->type = DIRECTIONAL_LIGHT;
    
    [self addLight:light];
    
    light = (Light*)malloc(sizeof(Light));
    light->color = GLKVector3Make(1.5, 1.5, 1.5);
    light->direction = GLKVector3Make(0.0, 0.0, -1.0);
    light->position = GLKVector3Make(0.0, 0.0, 2.0);
    light->size = 0.5;
    light->type = SPOT_LIGHT;
    
    [self addLight:light];
    
    [Renderer moveCamera:0 y:1 z:4];
    [Renderer rotateCamera:0.24 x:1 y:0 z:0];
    
}

+ (void)close {
    glDeleteProgram(program);
}

+ (void)draw: (CGRect)drawRect {
    
    // Set up the light uniforms
    for (int i = 0; i < [lights count]; i++) {
        Light* light;
        [lights[i] getValue:&light];
        glUniform1i(glGetUniformLocation(program, [[NSString stringWithFormat:@"lights[%d]%@", i, @".type"] UTF8String]), light->type);
        glUniform3f(glGetUniformLocation(program, [[NSString stringWithFormat:@"lights[%d]%@", i, @".color"] UTF8String]), light->color.r, light->color.g, light->color.b);
        glUniform3f(glGetUniformLocation(program, [[NSString stringWithFormat:@"lights[%d]%@", i, @".position"] UTF8String]), light->position.x, light->position.y, light->position.z);
        glUniform3f(glGetUniformLocation(program, [[NSString stringWithFormat:@"lights[%d]%@", i, @".direction"] UTF8String]), light->direction.x, light->direction.y, light->direction.z);
        glUniform1f(glGetUniformLocation(program, [[NSString stringWithFormat:@"lights[%d]%@", i, @".size"] UTF8String]), light->size);
    }
    
    glUniform1i(glGetUniformLocation(program, "numLights"), (GLuint)[lights count]);
    
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [models enumerateKeysAndObjectsUsingBlock:^(NSString* texture, NSMutableArray* models, BOOL* stop) {
        glUniform1i(uniforms[UNIFORM_TEXTURE], (unsigned int)[textures[texture] intValue]);
        
        for (int i = 0; i < [models count]; i++) {
            Model* m = models[i];
            
            GLKMatrix4 mvpMatrix = m.position;
            normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(mvpMatrix), NULL);
            glUniformMatrix4fv(uniforms[UNIFORM_MV_MATRIX], 1, FALSE, (const float *)mvpMatrix.m);
            
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
            glVertexAttrib4f(1, 1.0f, 1.0f, 1.0f, 1.0f);
            glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GLfloat), m.normals);
            glEnableVertexAttribArray(2);
            glVertexAttribPointer(3, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(GLfloat), m.texCoords);
            glEnableVertexAttribArray(3);
            glUniformMatrix4fv(uniforms[UNIFORM_MVP_MATRIX], 1, FALSE, (const float *)mvpMatrix.m);
            glDrawElements(GL_TRIANGLES, m.numIndices, GL_UNSIGNED_INT, m.indices);
        }
    }];
}

+ (void)addModel: (Model*)model texture:(NSString*)texture {
    if ([models objectForKey:texture] == nil) {
        [models setObject:[[NSMutableArray alloc] init] forKey:texture];
        [Renderer loadTexture:texture];
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
    uniforms[UNIFORM_MV_MATRIX] = glGetUniformLocation(program, "modelViewMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(program, "normalMatrix");
    uniforms[UNIFORM_PASS] = glGetUniformLocation(program, "passThrough");
    uniforms[UNIFORM_SHADEINFRAG] = glGetUniformLocation(program, "shadeInFrag");
    uniforms[UNIFORM_TEXTURE] = glGetUniformLocation(program, "texSampler");
    
    return true;
}

+ (void)loadTexture:(NSString *)fileName {
    CGImageRef img = [UIImage imageNamed:fileName].CGImage;
    if (!img) {
        NSLog(@"Failed to load image: %@", fileName);
        NSException *contextFailedException = [NSException
                                               exceptionWithName:@"GLESFailureException"
                                               reason:@"Failed to load image"
                                               userInfo: nil];
        @throw contextFailedException;
    }
    
    size_t w = CGImageGetWidth(img);
    size_t h = CGImageGetHeight(img);
    
    GLubyte* spriteData = (GLubyte *)calloc(w * h * 4, sizeof(GLubyte));
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, w, h, 8, w*4, CGImageGetColorSpace(img), kCGImageAlphaPremultipliedLast);
    
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, w, h), img);
    
    CGContextRelease(spriteContext);
    
    GLuint texName;
    glGenTextures(1, &texName);
    
    int val = (int)[textures count];
    
    glActiveTexture(GL_TEXTURE0 + val);
    glBindTexture(GL_TEXTURE_2D, texName);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)w, (int)h, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    free(spriteData);
    
    
    NSLog(@"Texture %@ loaded into texture %d", fileName, val);
    
    [textures setObject:[NSNumber numberWithInt:val] forKey:fileName];
    
}

+ (void)addLight:(Light *)light {
    [lights addObject:[NSValue valueWithPointer:light]];
}

@end
