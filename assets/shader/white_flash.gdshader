shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D sprite_texture : source_color, filter_nearest;
uniform bool white_override = false;

void fragment() {
    vec4 tex = texture(sprite_texture, UV);

    if (white_override) {
        ALBEDO = vec3(1.0);
    } else {
        ALBEDO = tex.rgb;
    }

    ALPHA = tex.a * COLOR.a;
}