shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D sprite_texture : source_color, filter_nearest;
uniform float white_amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec4 tex = texture(sprite_texture, UV);

    ALBEDO = mix(
        tex.rgb,
        vec3(1.0),
        white_amount
    );

    ALPHA = tex.a * COLOR.a;
}