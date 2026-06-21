shader_type canvas_item;
uniform float red_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec4 red_color : source_color = vec4(1.0, 0.2, 0.1, 1.0);
void fragment() {
	
    vec4 tex = texture(TEXTURE, UV);
    COLOR.rgb = mix(tex.rgb, red_color.rgb, red_amount);
    COLOR.a = tex.a;
}