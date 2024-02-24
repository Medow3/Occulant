shader_type canvas_item;

uniform sampler2D Screen : hint_screen_texture;
uniform sampler2D warp_tex : source_color, repeat_enable;

uniform float warp_tex_scale = 1.0;
uniform float warp_intensity = 1.0;
uniform float warp_time_scale = -0.3;

uniform float block_width = 0.45;
uniform float lump_width = 0.5;
uniform float pulse_time_scale = 5;
uniform bool warp_vertically = true;
uniform float radial_fade_start = .1;
uniform float radial_fade_width = .1;
uniform vec4 border_color : source_color = vec4(0.3, 0.0, 0.0, 1.0);
uniform vec4 mirror_line_color : source_color = vec4(0.8, 0.5, 0.5, 1.0);
uniform vec2 player_center_offset = vec2(0.0);



// Mathew's original modulate colour: 7a8aff17

float lump(float x) {
	return pow(sin(PI * x), lump_width);
}

float block(float x) {
	return (abs(x-0.5) > block_width ? 0.0 : 1.0);
}

float outline(vec2 pos, float start, float stop) {
	vec2 v = abs(pos - vec2(0.5));
	if (v.x < start && v.y < start) return 0.0;
	if (v.x > stop || v.y > stop) return 0.0;
	return 1.0;
}

float radial_fade(vec2 pos, float start, float width) {
	float radius = distance(pos, vec2(0.5) + player_center_offset);
	if (radius < start) return 1.0;
	if (radius > start + width) return 0.0;
	return 0.5 * cos( PI / width * (radius - start) ) + 0.5;
}

float radial_fan(vec2 pos, float rot, float n) {
	float angle = (atan(pos.y - 0.5, pos.x - 0.5) + PI) + rot;
	return 0.5 * cos(angle * n) + 0.5;
}

float line(float x, float start, float width) {
	if (x < start + 0.5 - width / 2.0 || x > start +0.5 + width / 2.0) return 0.0;
	//return 0.5 * cos( TAU / width * (x - start - 0.5)) + 0.5;
	return 1.0;
}

float dividers(float direction, float spread, float width, float speed) {
	float d1 = line(direction, spread * 0.1 * fract(TIME * speed), width);
	float d2 = line(direction, spread * -0.1 * fract(TIME * speed), width);
	float d3 = line(direction, spread * 0.3 * fract(TIME * speed), width);
	float d4 = line(direction, spread * -0.3 * fract(TIME * speed), width);
	return (d1 + d2 + d3 + d4) / 4.0 * pow((0.5 * cos(TAU * (fract(TIME * speed) - 0.5)) + 0.5), .3);
}

void fragment() {
	
	// Calculate warp value
	vec4 warp_sampler = texture(warp_tex, (UV + TIME * warp_time_scale) * warp_tex_scale);
	float warp_val = (warp_sampler.x - 0.5) * 2.0 * warp_intensity / 100.0;
	
	float radial_fade_mask = (1.0 - radial_fade(UV,
		radial_fade_start + 0.05 * sin(pulse_time_scale * TIME),
		radial_fade_width));
		
	float warp_mask = min(lump(UV.x), lump(UV.y)) * radial_fade_mask;
	
	float ants = 0.5 * radial_fan(UV, 0.5 * TIME, 20.0) + 0.5 * radial_fan(UV, -.3 * TIME, 19.0);
	float border_mask = outline(UV, 0.49, 0.50);
	ants *= border_mask;
	
	float divs = dividers(warp_vertically ? UV.y : UV.x, 0.1, 0.02, 0.5) *
		radial_fade_mask * (1.0 - border_mask);
	
	float warp_dir = float(warp_vertically);
	COLOR = texture(Screen, SCREEN_UV + 
		vec2(warp_val * (1.0 - warp_dir), warp_val * warp_dir) * warp_mask)
		+ vec4(ants, ants, ants, 0.0) * border_color
		+ vec4(divs, divs, divs, 0.0) * mirror_line_color;
	
	// Uncomment to preview noise
	//COLOR = texture(warp_tex, (UV + TIME * warp_time_scale) * warp_tex_scale);
	
	//float t = radial_fade(UV , 0.05, 0.0);
	//COLOR = vec4(t, t, t, t * .5);
}