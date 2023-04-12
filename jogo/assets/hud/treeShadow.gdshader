shader_type canvas_item;

void vertex() {
	VERTEX.y += sin(TIME * 2.0 + VERTEX.x * 50.0) * 5.0;
}
