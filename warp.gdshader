shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
uniform float warp_intensity : hint_range(0.0, 2.0) = 1.0; 
uniform float position : hint_range(0.0, 1.0) = 0.5;

void fragment() {
    vec2 uv = SCREEN_UV;
	
	if (uv.x > position) {
		uv.x = 1.0 - uv.x;
		uv.x /= clamp((1.0 - uv.x)*warp_intensity,0.0,1.0);
		uv.x = 1.0 - uv.x;
		uv.x = clamp(uv.x,position,1);
	}
	else {
		uv.x /= clamp((1.0 - uv.x)*warp_intensity,0.0,1.0);
		uv.x = clamp(uv.x,0.0,position);
	}
    
    COLOR = texture(SCREEN_TEXTURE, uv);
}
