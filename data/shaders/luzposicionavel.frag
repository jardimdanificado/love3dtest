// variables provided by g3d's vertex shader
varying mediump vec4 worldPosition;
varying mediump vec3 vertexNormal;

// the model matrix comes from the camera automatically
uniform mediump mat4 modelMatrix;

// value given by main program
uniform mediump vec3 lightPosition;

// constant values
uniform mediump float light_dist = 10.0;
uniform mediump float ambient = 0.2;

vec4 effect(vec4 color, sampler2D texture, vec2 texture_coords, vec2 screen_coords) {

    // Get the current pixel, if alpha is zero return nothing

    mediump vec4 pixel = texture2D(texture, texture_coords);
    if (pixel.a == 0.0) discard;

    // Get the distance between the light position and the point in the world

    mediump vec3 delta_pos = lightPosition.xyz - worldPosition.xyz;
    mediump float dist = length(delta_pos);

    if (dist > light_dist)
        return vec4(pixel.rgb * ambient, 1.0) * color;

    // Computed by the dot product of the normal vector and the direction to the light source

    mediump vec3 lightDirection = normalize(delta_pos);
    mediump vec3 normal = normalize(mat3(modelMatrix) * vertexNormal);
    mediump float diffuse = max(dot(lightDirection, normal), 0.0);

    // Calculate the final brightness, taking into account the distance that light can travel and ambient value

    mediump float lightness = max(diffuse * smoothstep(light_dist, 0.0, dist) + ambient, ambient);

    return vec4((pixel.rgb * color.rgb) * lightness, 1.0);

}
