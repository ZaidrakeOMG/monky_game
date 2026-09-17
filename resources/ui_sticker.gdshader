shader_type canvas_item;
render_mode unshaded;

// Acabado tipo sticker/caricatura para que todos los iconos de Wonky
// compartan el mismo borde aunque las ilustraciones originales sean distintas.
uniform vec4 outline_color : source_color = vec4(0.075, 0.050, 0.035, 1.0);
uniform float outline_size : hint_range(0.0, 14.0, 0.5) = 7.0;
uniform vec2 shadow_offset = vec2(0.0, 5.0);
uniform vec4 shadow_color : source_color = vec4(0.02, 0.01, 0.01, 0.28);

float tex_alpha(vec2 uv) {
	return texture(TEXTURE, uv).a;
}

void fragment() {
	vec4 src = texture(TEXTURE, UV);
	vec2 px = TEXTURE_PIXEL_SIZE * outline_size;

	float around = 0.0;
	around = max(around, tex_alpha(UV + vec2( px.x, 0.0)));
	around = max(around, tex_alpha(UV + vec2(-px.x, 0.0)));
	around = max(around, tex_alpha(UV + vec2(0.0,  px.y)));
	around = max(around, tex_alpha(UV + vec2(0.0, -px.y)));
	around = max(around, tex_alpha(UV + vec2( px.x,  px.y) * 0.72));
	around = max(around, tex_alpha(UV + vec2(-px.x,  px.y) * 0.72));
	around = max(around, tex_alpha(UV + vec2( px.x, -px.y) * 0.72));
	around = max(around, tex_alpha(UV + vec2(-px.x, -px.y) * 0.72));

	float outline_alpha = clamp(around - src.a, 0.0, 1.0);
	vec2 shadow_uv_offset = TEXTURE_PIXEL_SIZE * shadow_offset;
	float shifted = tex_alpha(UV - shadow_uv_offset);
	float shadow_alpha = clamp(shifted - max(src.a, outline_alpha), 0.0, 1.0) * shadow_color.a;

	vec3 rgb = shadow_color.rgb;
	float a = shadow_alpha;
	if (outline_alpha > 0.001) {
		rgb = mix(rgb, outline_color.rgb, outline_alpha);
		a = max(a, outline_alpha * outline_color.a);
	}
	if (src.a > 0.001) {
		rgb = mix(rgb, src.rgb, src.a);
		a = max(a, src.a);
	}

	COLOR = vec4(rgb, a);
}
