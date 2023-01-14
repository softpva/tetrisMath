
extends Button

var text = '' 
var hiddenText = false setget setText
var fixSize = Vector2()
var theme = Theme.new()


func _ready():
	theme.set_color("font_color", "Button", Color(1,1,0))
	set_theme(theme)
	set_flat(true)

func setText():
	if( hiddenText ):
		text = get_text()
		self.set_text('')

func getText():
	return text

