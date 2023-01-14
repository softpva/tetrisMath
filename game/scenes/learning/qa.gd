
extends Control

var text = 'testando o controle'
var numChars = text.length()
var mouseEnter = false
var fDynFontData = DynamicFontData.new()
var fDynFont = DynamicFont.new()
var fontSize = 0
var fontSpace = 0

func _ready():
	set_focus_mode(FOCUS_ALL)
	fDynFontData.set_font_path("./fonts/Lato-Regular.ttf")
	fDynFont.set_font_data(fDynFontData)
	fDynFont.set_size(18)
	fontSize = fDynFont.get_size()
	fontSpace = fDynFont.get_spacing(1)
	set_size(Vector2(fontSize*numChars/2,fontSize))
	set_pos(Vector2(0,100))
	set_process(true)

func _process(delta):
	update()

func _draw():
	if( has_focus() or mouseEnter):
		draw_rect(Rect2(Vector2(0,0),get_size()), Color(1,0,0))
		draw_string(fDynFont,Vector2(7,fontSize*0.8),text,Color(0,1,1) )
	else:
		draw_rect(Rect2(Vector2(0,0),get_size()), Color(0,0,0))
		draw_string(fDynFont,Vector2(7,fontSize*0.8),text,Color(1,1,1) )

func _notification(what):
	if( what == NOTIFICATION_MOUSE_ENTER ):
		mouseEnter = true
	elif( what == NOTIFICATION_MOUSE_EXIT ):
		mouseEnter = false
