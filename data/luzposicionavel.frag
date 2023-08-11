// variables provided by g3d's vertex shader
varying vec4 worldPosition;
varying vec3 vertexNormal;

// the model matrix comes from the camera automatically
uniform mediump mat4 modelMatrix;

// value given by main program
uniform vec3 lightPosition;

// constant values
uniform float light_dist = 10;
uniform float ambient = 0.2;


vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {

    // Get the current pixel, if alpha is zero return nothing

    vec4 pixel = Texel(texture, texture_coords);
    if (pixel.a == 0.0) discard;

    // Get the distance between the light position and the point in the world

    vec3 delta_pos = lightPosition.xyz - worldPosition.xyz;
    float dist = length(delta_pos);

    if (dist > light_dist)
        return vec4(pixel.rgb * ambient, 1.0) * color;

    // Computed by the dot product of the normal vector and the direction to the light source

    vec3 lightDirection = normalize(delta_pos);
    vec3 normal = normalize(mat3(modelMatrix) * vertexNormal);
    float diffuse = max(dot(lightDirection, normal), 0.0);

    // Calculate the final brightness, taking into account the distance that light can travel and ambient value

    float lightness = max(diffuse * smoothstep(light_dist, 0.0, dist) + ambient, ambient);

    return vec4((pixel.rgb * color.rgb) * lightness, 1.0);

}