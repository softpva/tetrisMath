extends Container

var aOrigString = []
var aQuestionButtons = []
var aAnswerButtons = []
var LearnButton = preload("learnButton.gd")
var pos = Vector2(0,0)
var sep = Vector2(-10,0)

# NEXTs:
	# The core must be manipulated on data structure and the gui is just consequence, create it
	# The code after |c, where c is a character that define:
		# |h>Text...|  h Hides de Text, sets size of button and puts the second and hot hide button on the answer ie: |h>o céu é azul
		# |n>Notes...| n all text are ignorated and don't create button, use to note anything
		# |i>Text...| i is used to initial information for the kind of question or database, etc., ie: |i>História 9ano Enem... 


func _ready():
	var strQTest = "|Pedro|| Álvares Cabral descobriu o |Brasil| em |22 de abril de 1500| quando viajava para a |India|"
	buildQuestion(strQTest)
	
func buildQuestion(s):
	var bt = null
	if( s != ''):
		aOrigString = s.split('|')
		for sAux in aOrigString:
			if( sAux == '' or ( sAux[0] == 'n' and sAux[1] =='>' ) ):
				continue
			elif( sAux[0] == 'h' and sAux[1] == '>' ):
				pass
			bt = LearnButton.new()
			bt.set_text(sAux)
			add_child(bt, true)
			bt.set_pos(pos)
			pos.x += bt.get_size().x + sep.x
			if( bt.get_size().x + pos.x > self.get_size().x):
				pos.x = 0
				pos.y += bt.get_size().y + sep.y
			print(bt.get_name())
		bt = get_node("Button 3")
		print(bt.get_size())
		print(bt.get_position_in_parent())
		print(bt.get_text())

func createButton():
	pass 

func plotQuestion():
	pass

func plotAswers():
	pass