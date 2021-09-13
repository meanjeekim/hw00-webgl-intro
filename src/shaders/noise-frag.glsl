#version 300 es

// This is a fragment shader. If you've opened this file first, please
// open and read lambert.vert.glsl before reading on.
// Unlike the vertex shader, the fragment shader actually does compute
// the shading of geometry. For every pixel in your program's output
// screen, the fragment shader is run for every bit of geometry that
// particular pixel overlaps. By implicitly interpolating the position
// data passed into the fragment shader by the vertex shader, the fragment shader
// can compute what color to apply to its pixel based on things like vertex
// position, light position, and vertex color.
precision highp float;

uniform vec4 u_Color; // The color with which to render this instance of geometry.

// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

vec3 hash(vec3 p) {
    p = vec3( dot(p,vec3(127.1,311.7, 74.7)),
			  dot(p,vec3(269.5,183.3,246.1)),
			  dot(p,vec3(113.5,271.9,124.6)));

	return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}

float noise(vec3 p)
{
    vec3 indices = floor(p);
    vec3 fracts = fract(p);

    vec3 u = fracts*fracts*(3.0-2.0*fracts);

    return mix( mix( mix(  dot(  hash( indices + vec3(0.0,0.0,0.0)),  fracts - vec3(0.0,0.0,0.0)),
                           dot(  hash( indices + vec3(1.0,0.0,0.0)),  fracts - vec3(1.0,0.0,0.0)), u.x),
                     mix(  dot(  hash( indices + vec3(0.0,1.0,0.0)),  fracts - vec3(0.0,1.0,0.0)),
                           dot(  hash( indices + vec3(0.0,0.0,1.0)),  fracts - vec3(0.0,0.0,1.0)), u.x), u.y),
                mix( mix(  dot(  hash( indices + vec3(0.0,0.0,1.0)),  fracts - vec3(0.0,0.0,1.0)),
                           dot(  hash( indices + vec3(1.0,0.0,1.0)),  fracts - vec3(1.0,0.0,1.0)), u.x),
                     mix(  dot(  hash( indices + vec3(0.0,1.0,1.0)),  fracts - vec3(0.0,1.0,1.0)),
                           dot(  hash( indices + vec3(1.0,1.0,1.0)),  fracts - vec3(1.0,1.0,1.0)), u.x), u.y), u.z);
}

void main()
{
    // Material base color (before shading)
        vec4 diffuseColor = u_Color;

        // Calculate the diffuse term for Lambert shading
        float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
        // Avoid negative lighting values
        // diffuseTerm = clamp(diffuseTerm, 0, 1);

        float ambientTerm = 0.2;

        float lightIntensity = diffuseTerm + ambientTerm;   //Add a small float value to the color multiplier
                                                            //to simulate ambient lighting. This ensures that faces that are not
                                                            //lit by our point light are not completely black.

        // Compute final shaded color
        // out_Col = vec4(diffuseColor.rgb * lightIntensity, diffuseColor.a);

        vec3 col = vec3(noise(fs_Pos.rgb * 20.0));

        out_Col = vec4(col, 1.0);
}
