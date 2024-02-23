shader_type canvas_item;

uniform vec3 color_a: source_color = vec3(0.5);
uniform vec3 color_b: source_color = vec3(0.5);
uniform vec3 color_c: source_color = vec3(1.0);
uniform vec3 color_d: source_color = vec3(0.0, 0.33, 0.67);
uniform int iterations: hint_range(1, 50, 1) = 10;
uniform float speed: hint_range(0.1, 10.0) = 1.0;
uniform float zoom: hint_range(0.1, 5.0) = 1.0;
uniform float subtract: hint_range(0.1, 1.0) = 0.5;
uniform float multiply: hint_range(1.0, 2.0) = 1.1;

vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
	return a + b * cos(2.0 * PI * (c * t + d));
}

vec2 rotate(vec2 uv, float angle) {
	return uv * mat2(
			vec2(cos(angle), -sin(angle)),
			vec2(sin(angle), cos(angle))
		);
}

vec3 invert_color(vec3 color, float intensity) {
	return mix(color.rgb, 1.0 - color.rgb, intensity);
}

void fragment() {
	float time = TIME;
	float angle = time * speed * 0.1;
	vec2 uv = (SCREEN_UV - 0.5) / vec2(SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y, 1.0);
	vec3 color = vec3(0.0);
	uv /= zoom + sin(time * 0.1) * 0.5 + 0.5;
	for (int i = 0; i < iterations; i++) {
		uv = rotate((abs(uv) - subtract) * multiply, angle);
	}
	vec3 p = palette(length(uv) + dot(uv, uv), color_a, color_b, color_c, color_d);
	color = clamp(vec3(length(uv) * p), vec3(0.0), vec3(1.0));
	float intensity = sin(time) * 0.25 - 0.2;
	color = invert_color(color, intensity);
	COLOR = vec4(color, 1.0);
}
