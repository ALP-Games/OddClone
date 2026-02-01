shader_type spatial;

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
	// Called for every pixel the material is visible on.
	ALBEDO = vec3(1.0, 0.0, 0.0); // Example: Solid red overlay
	ALPHA = 0.5;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
