extends Panel

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	set_size(Vector2(200,400))
	update()

func testColor(r=1,g=1,b=1,a=1):
	draw_rect(Rect2(0,0,200,25),Color(r,g,b,a))
	draw_rect(Rect2(0,25,200,25),Color(1.0,0.5,0.0,a))
	draw_rect(Rect2(0,50,200,25),Color(1.0,0.5,0.5,a))
	draw_rect(Rect2(0,75,200,25),Color(0.5,0.5,0.5,a))
	draw_rect(Rect2(0,100,200,25),Color(1.0,1.0,0.0,a))
	draw_rect(Rect2(0,125,200,25),Color(0.5,1.0,0.0,a))
	draw_rect(Rect2(0,150,200,25),Color(0.0,1.0,1.0,a))
	draw_rect(Rect2(0,175,200,25),Color(1.0,1.0,0.5,a))
	
	

func _draw():
	pass
#	testColor()