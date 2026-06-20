shader_type canvas_item;

uniform float blue_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec4 blue_color : source_color = vec4(0.1, 0.3, 1.0, 1.0);

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    COLOR.rgb = mix(tex.rgb, blue_color.rgb, blue_amount);
    COLOR.a = tex.a;
}