extends Control

var pic = preload("./assets/block32x32px.png")

func _ready():
	set_process_input(true)

func _draw():
	draw_texture_rect(pic, Rect2(200,400,40,40),false, Color(1,1,1))




func _on_HButtonArray_button_selected( button_idx ):
	if ( button_idx == 0 ):
		get_node("particles").set_pos(Vector2(220,420))
		get_node("particles").set_emitting(true)
		get_node("particles").set_emit_timeout(0.2)