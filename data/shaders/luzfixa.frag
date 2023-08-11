// variables provided by g3d's vertex shader
varying mediump vec4 worldPosition;
varying mediump vec3 vertexNormal;

// the model matrix comes from the camera automatically
uniform mediump mat4 modelMatrix;
uniform mediump vec3 lightPosition;
uniform mediump float ambient;

#ifdef VERTEX
// Vertex shader code here
void main() {
    // Transform vertex position and normal using the model matrix
    worldPosition = modelMatrix * gl_Vertex;
    vertexNormal = mat3(modelMatrix) * gl_Normal;

    // Set gl_Position
    gl_Position = ftransform();
}
#endif

#ifdef PIXEL
// Fragment shader code here
vec4 effect(vec4 color, sampler2D tex, vec2 texcoord, vec2 pixcoord) {
    // diffuse light
    // computed by the dot product of the normal vector and the direction to the light source
    mediump vec3 lightDirection = normalize(lightPosition.xyz - worldPosition.xyz);
    mediump vec3 normal = normalize(vertexNormal);
    mediump float diffuse = max(dot(lightDirection, normal), 0.0);

    // get color from the texture
    mediump vec4 texcolor = texture2D(tex, texcoord);

    // if this pixel is invisible, get rid of it
    if (texcolor.a == 0.0) {
        discard;
    }

    // draw the color from the texture multiplied by the light amount
    mediump float lightness = diffuse + ambient;
    return vec4((texcolor * color).rgb * lightness, 1.0);
}
#endif
