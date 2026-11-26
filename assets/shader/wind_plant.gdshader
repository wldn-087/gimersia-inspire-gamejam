
shader_type spatial;
render_mode cull_disabled;

uniform sampler2D albedo_texture : source_color;
uniform float wind_strength = 0.12;
uniform float wind_speed = 2.0;
uniform float plant_height = 2.0;
uniform float alpha_threshold = 0.5;

void vertex() {
    // Bagian bawah tanaman lebih sulit bergerak.
    float height_factor = clamp(VERTEX.y / plant_height, 0.0, 1.0);
    height_factor = smoothstep(0.0, 1.0, height_factor);

    // Gerakan angin.
    float wave = sin(
        TIME * wind_speed +
        VERTEX.x * 1.5 +
        VERTEX.z * 1.5
    );

    float sway = wave * wind_strength * height_factor;

    VERTEX.x += sway;
}

void fragment() {
    vec4 tex = texture(albedo_texture, UV);

    ALBEDO = tex.rgb;
    ALPHA = tex.a;

    // Menghilangkan bagian transparan sepenuhnya.
    ALPHA_SCISSOR_THRESHOLD = alpha_threshold;

    ROUGHNESS = 1.0;
}
