// variables provided by g3d's vertex shader
varying mediump vec4 worldPosition;
varying mediump vec3 vertexNormal;

// the model matrix comes from the camera automatically
uniform mediump mat4 modelMatrix;
uniform mediump vec3 lightPosition;
uniform mediump float ambient;

vec4 effect(vec4 color, sampler2D tex, vec2 texcoord, vec2 pixcoord) {
    // diffuse light
    // computed by the dot product of the normal vector and the direction to the light source
    mediump vec3 lightDirection = normalize(lightPosition.xyz - worldPosition.xyz);
    mediump vec3 normal = normalize(mat3(modelMatrix) * vertexNormal);
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
