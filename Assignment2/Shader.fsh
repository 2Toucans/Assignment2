#version 300 es

#define LIGHT_TYPE_DIRECTIONAL 0
#define LIGHT_TYPE_SPOT 1

precision highp float;
in vec4 v_color;
in vec3 v_position;
in vec3 v_normal;
in vec2 v_texcoord;
out vec4 o_fragColor;

struct Light {
    int type;
    vec3 color;
    vec3 position;
    vec3 direction;
    float size;
};


uniform sampler2D texSampler;

uniform mat4 modelViewProjectionMatrix;
uniform mat4 modelViewMatrix;
uniform mat3 normalMatrix;
uniform bool passThrough;
uniform bool shadeInFrag;
uniform Light lights[10];
uniform int numLights;

void main()
{
    if (!passThrough && shadeInFrag) {
        vec3 eyeNormal = normalize(normalMatrix * v_normal);
        vec4 diffuseColor = vec4(1.0, 1.0, 1.0, 1.0);
        vec4 brightness = vec4(0.4, 0.4, 0.4, 0.0);
        
        for (int i = 0; i < numLights; i++) {
            vec3 lightPosition;
            float nDotVP;
            switch (lights[i].type) {
                case LIGHT_TYPE_DIRECTIONAL:
                    lightPosition = vec3(-lights[i].direction.x, -lights[i].direction.y, -lights[i].direction.z);
                    nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
                    brightness += vec4(nDotVP * lights[i].color, 0.0);
                    break;
                case LIGHT_TYPE_SPOT:
                    lightPosition = vec3(-lights[i].direction.x, -lights[i].direction.y, -lights[i].direction.z);
                    nDotVP = max(0.2, dot(eyeNormal, normalize(lightPosition)));
                    vec3 lightDistDir = normalize(v_position - lights[i].position);
                    float dirDotDist = max(0.0, dot(lightDistDir, normalize(-lightPosition)));
                    brightness += dirDotDist > cos(lights[i].size) ? vec4(nDotVP * lights[i].color, 0.0) : vec4(0, 0, 0, 0);
                    break;
            }
        }
        
        o_fragColor = brightness * diffuseColor * texture(texSampler, v_texcoord);
    } else {
        o_fragColor = v_color;
    }
}

