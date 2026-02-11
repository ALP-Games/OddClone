shader_type canvas_item;

uniform sampler2D some_texture: source_color,repeat_disable;
uniform float fade: hint_range(0, 1.0, 0.001) = 1.0;


void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 tex = texture(some_texture, UV);
	COLOR.rgb = tex.rgb;
	COLOR.a = fade;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
