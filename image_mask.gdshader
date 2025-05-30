shader_type canvas_item;

uniform sampler2D albedo : source_color;
uniform vec3 replace_color;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 main_texture = texture(SCREEN_TEXTURE, SCREEN_UV);
	if (main_texture.rgb == replace_color) {
		vec4 noise_texture = texture(albedo, SCREEN_UV);
	COLOR = vec4(noise_texture.rgba);
	}
	else{
		COLOR = vec4(0.0,0.0,0.0,0.0);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
