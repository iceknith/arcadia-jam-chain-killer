shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float force = 1;
uniform vec2 displacement = vec2(5.0, 0);
uniform vec2 noise_displacement = vec2(0.0, 5.0);
uniform sampler2D noise;

void fragment()
{
	vec2 uv = SCREEN_UV + texture(noise, SCREEN_UV).r * force * force * noise_displacement * SCREEN_PIXEL_SIZE;
	
	float r = texture(SCREEN_TEXTURE, uv + vec2(-SCREEN_PIXEL_SIZE*force*displacement), 0.0).r;
	float g = texture(SCREEN_TEXTURE, uv, 0.0).g;
	float b = texture(SCREEN_TEXTURE, uv + vec2(SCREEN_PIXEL_SIZE*force*displacement), 0.0).b;
	
	COLOR = vec4(r, g, b, 1.0);
}