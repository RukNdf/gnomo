shader_type canvas_item;

void vertex() {
	float prevX = VERTEX.x;
	VERTEX.x += sin(TIME * 0.7 + VERTEX.y * 30.0) * 5.0;
	VERTEX.y += sin(TIME * 0.7 + prevX * -30.0) * 1.5;
}
