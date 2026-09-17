shader_type canvas_item;

uniform float scroll_offset : hint_range(0.0, 1.0) = 0.0;
uniform float horizon : hint_range(0.0, 0.9) = 0.34;
uniform float far_half_width : hint_range(0.001, 0.5) = 0.018;
uniform float near_half_width : hint_range(0.1, 0.5) = 0.47;
uniform float perspective_power : hint_range(0.1, 3.0) = 0.85;
uniform float vertical_tiles : hint_range(0.5, 8.0) = 2.7;
uniform float edge_softness : hint_range(0.0, 0.08) = 0.012;

void fragment() {
    vec2 uv = UV;
    if (uv.y < horizon) {
        COLOR = vec4(0.0);
        return;
    }

    float p = clamp((uv.y - horizon) / max(0.0001, (1.0 - horizon)), 0.0, 1.0);
    float half_w = mix(far_half_width, near_half_width, pow(p, perspective_power));
    float local_x = (uv.x - 0.5) / max(0.0001, half_w * 2.0) + 0.5;

    if (local_x < 0.0 || local_x > 1.0) {
        COLOR = vec4(0.0);
        return;
    }

    float source_y = fract(p * vertical_tiles - scroll_offset);
    vec4 col = texture(TEXTURE, vec2(local_x, source_y));

    float horizon_fade = smoothstep(horizon, horizon + 0.03, uv.y);
    float edge = min(local_x, 1.0 - local_x);
    float edge_fade = smoothstep(0.0, edge_softness, edge);
    col.a *= horizon_fade * edge_fade;
    COLOR = col;
}
