extends Label
var timer = Timer.new()
var text = ''



func _ready():
	timer.set_wait_time(0.5)
	timer.connect( "timeout",self,"pieceMoveDown", [true] )
	text = self.get_text()
	self.set_text('')
	
func putText():
	var aux = ''
	for s in range(text.length()):
		aux += text[s]
		set_text(aux)
	


