shader_type canvas_item;

uniform sampler2D some_texture: source_color,repeat_disable;

uniform float dissolve : hint_range(0, 1) = 1.0;
uniform float block_size = 16.0;
uniform float randomness : hint_range(0, 1) = 0.5;
uniform vec3 glow_color: source_color = vec3(1.0, 0.7, 0.3);
uniform float flicker_intensity : hint_range(0, 1) = 0.5;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 tex = texture(some_texture, UV);
	
	// Calculate block coordinates
	vec2 block_uv = floor(UV * block_size) / block_size;
	
	// Add random offset per block
	float block_seed = fract(sin(dot(block_uv, vec2(12.9898, 78.233))) * 43758.5453);
	float random_offset = block_seed * randomness;
	
	// Block-based dissolve
	float block_dissolve = dissolve * 1.7;
	float block_threshold = (1.0 - UV.y) + random_offset;
	
	// Calculate flicker based on block position and dissolve progress
    // Creates a pattern without if statements
    float flicker_pattern = fract(block_uv.x * 7.3 + block_uv.y * 13.7) * 2.0 - 1.0;
    flicker_pattern = abs(flicker_pattern); // 0-1 range
    
    // Calculate if block is in dissolving zone (0 = solid, 1 = dissolved)
    float dissolve_zone = smoothstep(block_dissolve - 0.2, block_dissolve, block_threshold);
    
    // Calculate if block is in flicker zone (edge area)
    float flicker_zone = smoothstep(block_dissolve - 0.15, block_dissolve - 0.05, block_threshold);
    flicker_zone *= (1.0 - smoothstep(block_dissolve - 0.05, block_dissolve, block_threshold));
    
    // Flicker intensity based on block seed
    float flicker_strength = flicker_pattern * flicker_intensity * flicker_zone;
    
    // Combine effects
    float visibility = 1.0 - dissolve_zone; // 1 = visible, 0 = invisible
    
    // Apply flicker to visibility
    visibility += flicker_strength;
    visibility = clamp(visibility, 0.0, 1.0);
    
    // Calculate glow
    float glow = flicker_zone * flicker_strength;
    
    // Final color
    vec3 final_color = mix(tex.rgb, glow_color, glow * 0.7);
    final_color += glow_color * glow * 2.0; // Additive glow
    
	COLOR.rgb = final_color;
	COLOR.a = tex.a * visibility;
    //ALBEDO = final_color;
    //ALPHA = tex.a * visibility;
    //EMISSION = glow_color * glow * 3.0;
	//color.g = 0.0;
	//color.b = 0.0;
	//COLOR.a = 0.0;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
