shader_type canvas_item;

const float STRIPES = 48.0;

uniform float flip = 0.0;

float noise(vec2 co) {
	return fract(sin(dot(co, vec2(12.9898,78.233))) * 43758.5453);
}

void fragment() {
	float x_flip = step(0.5, flip);

	float stripe_coord = UV.x - mod(UV.x, 1.0 / STRIPES);
	float offset = 0.5 * noise(vec2(0.0, stripe_coord));
	float y_flip = (
		(1.0 - x_flip) * clamp(0.5 * (flip - offset) / (0.5 - offset), 0.0, 0.5)
		+ x_flip * clamp((0.5 * (flip - 0.5) / offset) + 0.5, 0.5, 1.0)
	);
	y_flip = (0.5 / abs(- y_flip + 0.5));

	vec2 uv = vec2(x_flip + (1.0 - 2.0 * x_flip) * UV.x, y_flip + (1.0 - 2.0 * y_flip) * UV.y);
	COLOR.rgba = textureLod(SCREEN_TEXTURE, uv, 0.0);
}
