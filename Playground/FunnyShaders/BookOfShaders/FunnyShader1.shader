shader_type canvas_item;
render_mode unshaded;

// Credits to Danilo Guanabara for the main structure of the shader
// http://www.pouet.net/prod.php?which=57245

uniform float CURSOR : hint_range(0.0,1.0);

void fragment(){
//	vec2 final_uv = UV + vec2(CURSOR,0.0);
//	COLOR = vec4(final_uv,0.0,1.0);
//	COLOR = texture(TEXTURE,final_uv);
	float custom_cursor = sin(TIME) * 5.0;
	vec2 offset_uv = UV + vec2(-0.25,-0.25);
	float c1;
	float c2;
	float c3;
	vec2 r = vec2(0.5,0.5);
	float l,z=custom_cursor;
	for(int i=0;i<3;i++) {
		vec2 uv,p=offset_uv/r;
		uv=p;
		p-=0.5;
		p.x*=r.x/r.y;
		z+=0.15;
		l=length(p);
		uv+=p/l*(sin(z)+1.)*abs(sin(l*9.0-z*1.0));
		switch(i){
			case 0:
				c1=0.01/length(abs(mod(uv,1.0)-0.5));
				break;
			case 1:
				c2=0.01/length(abs(mod(uv,1.0)-0.5));
				break;
			case 3:
				c3=0.01/length(abs(mod(uv,1.0)-0.5));
				break;
		}
	}
	COLOR=vec4(c1/l,c2/l,c3/l,1.0);
}