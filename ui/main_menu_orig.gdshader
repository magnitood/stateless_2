shader_type canvas_item;

#define ITE_MAX 14

void vertex() {
	// Called for every vertex the material is visible on.
}

vec3 tex(vec2 uv) {
    vec3 c = vec3(fract(uv.xyy));
    if (mod(uv.x * 2.0, 2.0) < 0.9) return vec3(0.0);
    if (mod(uv.y * 1.0, 1.0) < 0.9) return vec3(0.0);
    return c;
}

void fragment() {
    float M = TIME * 0.5;
    float fog = 1.0;

    vec2 uv = vec2(2) * UV - vec2(1);
    vec2 res = 1.0/SCREEN_PIXEL_SIZE;

    uv *= vec2(res.x / res.y, 1.0);
    vec3 c = vec3(0.0);
    for (int i = 0; i < ITE_MAX; i++) {
        c = tex(vec2(uv.x / abs(uv.y / (float(i) + 1.0)) + M + 0.015, abs(uv.y)));
        if (length(c) > 0.5) break;
        uv = uv.yx * 1.3;
        fog *= 0.9;
    }

    vec4 fragColor = (1.0 - vec4(c.xyyy * (fog * fog)));
    fragColor.a = 1.0;
    // fragColor.a = fog;

    COLOR = fragColor;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
