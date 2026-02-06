shader_type spatial;
render_mode unshaded, cull_disabled, alpha_to_coverage; // alpha_to_coverage_and_one;

uniform float vframes = 1.0;
uniform float y_offset = 0.0;
uniform sampler2D albedo_texture : source_color;

uniform float alpha_scissor_threshold : hint_range(0.0, 1.0, 0.0001) = 0.5;
//uniform float alpha_antialiasing_edge : hint_range(0.0, 1.0, 0.0001);

uniform float dissolve : hint_range(0, 1) = 1.0;
uniform float block_size = 16.0;
uniform float randomness : hint_range(0, 1) = 0.5;
uniform vec3 glow_color: source_color = vec3(1.0, 0.7, 0.3);
uniform float flicker_intensity : hint_range(0, 1) = 0.5;


void vertex() {
	vec3 local_up = MODEL_MATRIX[1].xyz;
	//cross of:
	//	local_transform.basis.y     and    to_world(view_space.forward)
	//normalized
	//(represents right direction)
	vec4 ax = vec4(normalize(cross(local_up, INV_VIEW_MATRIX[2].xyz)), 0.0);
	//local_transform.basis.y
	//(represents up direction)
	vec4 ay = vec4(local_up.xyz, 0.0);
	//cross of:
	//	to_world(view_space.right)    and    local_transform.basis.y
	//(represents forward direction)
	vec4 az = vec4(normalize(cross(INV_VIEW_MATRIX[0].xyz, local_up)), 0.0);
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(ax, ay, az, MODEL_MATRIX[3]);
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
}


void fragment() {
	vec4 tex = texture(albedo_texture, UV);
	
	// Calculate block coordinates
	vec2 block_uv = floor(UV * block_size) / block_size;
	
	// Add random offset per block
	float block_seed = fract(sin(dot(block_uv, vec2(12.9898, 78.233))) * 43758.5453);
	float random_offset = block_seed * randomness;
	
	// Calculate dissolve position
	float pos = (UV.y * vframes) - y_offset;
	
	// Block-based dissolve
	float block_dissolve = dissolve * 1.7;
	float block_threshold = pos + random_offset;
	
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
    
    ALBEDO = final_color;
    ALPHA = tex.a * visibility;
    EMISSION = glow_color * glow * 3.0;
	
	//ivec2 texture_size = textureSize(albedo_texture, 0);
	
	ALPHA_SCISSOR_THRESHOLD = alpha_scissor_threshold;
	//ALPHA_ANTIALIASING_EDGE = alpha_antialiasing_edge;
	//ALPHA_TEXTURE_COORDINATE = UV * vec2(texture_size);
}
