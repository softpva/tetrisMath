
extends Control

var avBlockShapes = [
	[ Vector2(0,0)], # 1
	[ Vector2(0,0)],
	[ Vector2(0,0)],
	[ Vector2(0,0)],
	[ Vector2(0,0)],
	[ Vector2(0,0)],
	[ Vector2(0,0)],
	[ Vector2(0,0)],
	[ Vector2(0,0)],
	[ Vector2(0,0)], # 10
	[ Vector2(0,0)],
	[ Vector2(0,0)], # 12
	[ Vector2(0,0), Vector2(1,0)],
	[ Vector2(0,0), Vector2(1,0)],
	[ Vector2(0,0), Vector2(1,0)],
	[ Vector2(0,0), Vector2(1,0)], # 16
	[ Vector2(0,0), Vector2(1,0), Vector2(2,0)], # 18
	[ Vector2(0,0), Vector2(0,1), Vector2(0,2),Vector2(1,2)],
	[ Vector2(0,0), Vector2(0,1), Vector2(1,1),Vector2(1,2)]] # 20
	
var amvBlockRotations = [
	Matrix32(Vector2(1, 0), Vector2(0, 1), Vector2()),
	Matrix32(Vector2(0, 1), Vector2(-1, 0), Vector2()),
	Matrix32(Vector2(-1, 0), Vector2(0, -1), Vector2()),
	Matrix32(Vector2(0, -1), Vector2(1, 0), Vector2())]
var bHit = false
var bPieceActive = false
var bOnPause = false
var bExplodeAll = false
var btLanguage = null
var dCellsMap = {}
var dIni = {}
var dResult = {}
var fDynFontData = DynamicFontData.new()
var fDynFont = DynamicFont.new()
var iWidth = 0
var iHeight = 0
var iMaxShapes = 16
var iPieceShape = 0
var iPieceRotate = 0
var iPtos = 0
var iScore = 0
var iStage = 1
var lbScore = null
var lbStage = null
var lbWow = null
var oUnitaryBlock = preload("./ret100pxb.png")
var sBlockMath = ''
var sNumberSet = ''
var sOperatorSet = '+-*()'
var vPiecePosition = Vector2()
var vBlockColors = []
var vUnitSize = Vector2()
var vOrigin = Vector2()
var vDispl = Vector2(1,0)
var vLastCell = Vector2()
var vContactCell = Vector2()
var vStartPos = Vector2()
var timer 

# RULES AND SHORTCUTS OF THE GAME:
	# Points:
		# Each blue explosion you win  points 10 (20%) if a this is a number and points 50 (100%) if is an operator
		# Each empty map you add 100 points
		# Each red explosion you lost 50 points

# Think about:
	# Build the game where all stages can be acessed at any time, but a logic way must be walked to hit the history game 
	# include fatorial, exponential and roots, ie, monoOperators. This represents a deep recode of eval. See rpn theory
	# there will be two game format one with scenes and other more complete with a story: mathWorld and worldRebuild

# nexts, versão 0.6:
	# Change and unified the fonts-free to dynamic and set new font's size and colors
	# translate instructions labe 
	# build independent scenes
		# The present buttons are only to development, all they will be changed for minimal buttons that will run on smartphone
		# remove the pause button but maintein shortcut for development. (the horizontal movimento on line zero is a form of pause)
		# reforçar checklock com arquivo interno de última data, ou algo assim.
		# continue the refactoring
		# check recorrencies and dead functions, variables and objects

# Bugs:
	# DO NOT PERMIT THAT SIMPLE EQUALS COMPARATION HITS WHEN EXISTS an OPERATORS
	# Centralazied or eliminated the greatings
	# the geration of randon start number repeat much the last number generated
	
# Rules of code
	# functions sorted alphabetically ignoring the return prefix except alghoritms
	# change to the next or previous character
	
func sAdd(char, bAddIt ):
	var n = 0
	if ( bAddIt ):
		if ( char == '+' ) :
			return '-'
		if ( char == '-' ) :
			return '+'
		if ( char == '=' ) :
			return '9'
		if ( char == 'I' ) :
			return 'V'
		if ( char == 'V' ) :
			return 'X'
		if ( char == 'X' ) :
			return 'L'
		if ( char == 'L' ) :
			return 'C'
		if ( char == 'C' ) :
			return 'D'
		if ( char == 'D' ) :
			return 'M'
		if ( char == 'M' ) :
			return 'I'
		if ( char.is_valid_integer() ):
			n = int(char) + 1
			if ( n > 9 ) :
				return '0'
			else:
				return str(n)
		else:
			return char
	else:
		if ( char == '-' ) :
			return '+'
		if ( char == '+' ) :
			return '-'
		if ( char == '=' ) :
			return '1'
		if ( char == 'I' ) :
			return 'M'
		if ( char == 'V' ) :
			return 'I'
		if ( char == 'X' ) :
			return 'V'
		if ( char == 'L' ) :
			return 'X'
		if ( char == 'C' ) :
			return 'L'
		if ( char == 'D' ) :
			return 'C'
		if ( char == 'M' ) :
			return 'D'
		if ( char.is_valid_integer() ):
			n = int(char) - 1
			if ( n < 0 ) :
				return '9'
			else:
				return str(n)
		else:
			return char

# check the cell position in dCellsMap, if !='$" (empaty) or do not fit return false
func bCheckFit(vOffSet, iExtraRotate = 0):
	var i = -1
	for vc2Cell in avBlockShapes[iPieceShape]:
		i += 1
		# pos is set with vc2Cell in avBlockShapes[iPieceShape] in vPiecePosition
		# transformed by matrix of rotation + vOffSet
		var cellPos = vXformTransform(vc2Cell, iExtraRotate) + vOffSet
		if (cellPos.x < 0):
			return false
		if (cellPos.y < 0):
			return false
		if (cellPos.x >= iWidth):
			return false
		if (cellPos.y >= iHeight):
			return false
		if ( dCellsMap[cellPos] == '>' ):
			sBlockMath[i] = sAdd(sBlockMath[i], true)
		if ( dCellsMap[cellPos] == '<' ):
			sBlockMath[i] = sAdd(sBlockMath[i], false)
		if ( dCellsMap[cellPos] == '=' and cellPos.y == 1 ):
			sBlockMath[i] = '='
			return true
		if ( dCellsMap[cellPos] == 'I' and cellPos.y == 1 ):
			sBlockMath[i] = 'I'
			return true
		if ( dCellsMap[cellPos] == 'V' and cellPos.y == 1 ):
			sBlockMath[i] = 'V'
			return true
		if ( dCellsMap[cellPos] == 'X' and cellPos.y == 1 ):
			sBlockMath[i] = 'X'
			return true
		if ( dCellsMap[cellPos] == 'L' and cellPos.y == 1 ):
			sBlockMath[i] = 'L'
			return true
		if ( dCellsMap[cellPos] == 'C' and cellPos.y == 1 ):
			sBlockMath[i] = 'C'
			return true
		if ( dCellsMap[cellPos] == 'L' and cellPos.y == 1 ):
			sBlockMath[i] = 'L'
			return true
		if ( dCellsMap[cellPos] == 'M' and cellPos.y == 1 ):
			sBlockMath[i] = 'M'
			return true
		if ( dCellsMap[cellPos] == '+' and cellPos.y == 1 ):
			sBlockMath[i] = '+'
			return true
		if ( dCellsMap[cellPos] == '-' and cellPos.y == 1 ):
			sBlockMath[i] = '-'
			return true
		if ( dCellsMap[cellPos] == '*' and cellPos.y == 1 ):
			sBlockMath[i] = '*'
			return true
		if ( dCellsMap[cellPos] == '(' and cellPos.y == 1 ):
			sBlockMath[i] = '('
			return true
		if ( dCellsMap[cellPos] == ')' and cellPos.y == 1 ):
			sBlockMath[i] = ')'
			return true
		if ( dCellsMap[cellPos] == '/' and cellPos.y == 1 ):
			sBlockMath[i] = '/'
			return true
		if ( dCellsMap[cellPos] == '%' and cellPos.y == 1 ):
			sBlockMath[i] = '%'
			return true
		if ( dCellsMap[cellPos] != '$' and dCellsMap[cellPos] != '>' and dCellsMap[cellPos] != '<' ):
			vContactCell = cellPos
			vLastCell = vPiecePosition
			if  ( dCellsMap[cellPos] == '=' ):
				bExplodeAll = true
			else:
				bExplodeAll = false
			return false
	return true

func checkIfCellsMapIsEmpty( ):
	var c = 0
	var line_1 = 0
	for x in range(iWidth):
		if( dCellsMap[Vector2(x,1)] != '$' and  dCellsMap[Vector2(x,1)] != ' ' ):
			line_1 +=1
	if( line_1 > 2 ):
		line_1 -= 2
	else:
		line_1 = 0
	# count numbers of cells that exists on cellsMap
	for y in range(2,iHeight):
		for x in range(iWidth):
			if( dCellsMap[Vector2(x,y)] != '$' and  dCellsMap[Vector2(x,y)] != ' ' and\
			 dCellsMap[Vector2(x,y)] != '>' and  dCellsMap[Vector2(x,y)] != '<'):
				c += 1
	if( iScore > 2000 ):
		winStage()
	if( c == 0 ):
	# iStage:grade -> 1:35, 2:100, 3:63, 4:63, 5:99, 6:63, 7:121, 8:169
		iScore += 100
		lbScore.set_text(tr("SCORE") + str(iScore).pad_decimals(0) + ' / 1000')
		if( iStage ):
			if( iScore <100 ):
				# (% fill, number of set of operators)
				fillCellsMapWhenEmpty(6,2)
				# 35:2, 63:3, 99:5, 100:6, 121:7, 169:10
			elif( iScore == 100 ):
				fillCellsMapWhenEmpty(0,1)
			elif( iScore < 400 ):
				fillCellsMapWhenEmpty(7,2)
				# 35:2, 63:4, 99:6, 100:7, 121:8, 169:11
			elif( iScore < 700 ):
				fillCellsMapWhenEmpty(8,2)
				# 35:2, 63:5, 99:7, 100:8, 121:9, 169:13
			elif( iScore < 1000 ):
				fillCellsMapWhenEmpty(10,3)
				# 35:3, 63:6, 99:9, 100:10, 121:12, 169:16
			else:
				fillCellsMapWhenEmpty(0,0)
	update()

func winStage():
	lbScore.set_text("GREAT!!!  YOU WIN THIS STAGE")
####	call sceneClass with respective notification (sceneclass is the scene learning )

# lock the program in a fixed date
func checkLock():
	var aux = OS.get_datetime()
	if ( aux['month'] < 12 and aux['year'] == 2023):
		return(true)
	else:
		get_node("../btRestart").set_hidden(true)
		var textBbcode = 'Sorry...This game has expired\nDownload it again at\nwww.edu4u.com.br'
		get_node("../notes").set_bbcode(textBbcode)
		return(false)

# Just delete the column 'columnToDel' or the correspondent vectors
func delColumn(columnToDel, vColumn):
	var t = timer.get_wait_time()
	var x = -columnToDel-1
	var aux = [ 'GREET_1', 'GREET_2', 'GREET_3' ]
	lbWow.set_pos(vOrigin + Vector2(vUnitSize.x, iHeight*vUnitSize.y/2 + vUnitSize.y) )
	lbWow.set_text( tr(aux[randi() % aux.size()] ))
	lbWow.set_hidden( false )
	if ( bExplodeAll ):
		var iPts = 0.0
		for y in range(2,iHeight):
			timer.set_wait_time(0.25)
#			timer.disconnect("timeout",self,"pieceMoveDown")	pva
			if ( ! (dCellsMap[Vector2(x,y)] == ' ' or dCellsMap[Vector2(x,y)] == '$' or\
					 dCellsMap[Vector2(x,y)] == '>' or dCellsMap[Vector2(x,y)] == '<' ) ):
				yield(timer,"timeout")
				if( lbWow.is_hidden() ):
					lbWow.set_hidden( false )
				else:
					lbWow.set_hidden( true )
				# if cell is an operator add score in 100% else add score 20%
				if( dCellsMap[Vector2(x,y)].is_subsequence_of(sOperatorSet) ):
					iPts = 1
				else:
					iPts = 0.20
				explode(Vector2(x,y), iPts)
				dCellsMap[Vector2(x,y)] = '$'
				update()
	else:
		var iPts = 0.0
		var fAddPts = 2.0/iWidth
		for v in vColumn:
			timer.set_wait_time(0.25)
#			timer.disconnect("timeout",self,"pieceMoveDown")		pva
			if ( ! (dCellsMap[v] == ' ' or dCellsMap[v] == '$' or\
					 dCellsMap[v] == '>' or dCellsMap[v] == '<' ) ):
				yield(timer,"timeout")
				if( lbWow.is_hidden() ):
					lbWow.set_hidden( false )
				else:
					lbWow.set_hidden( true )
				if( dCellsMap[v].is_subsequence_of(sOperatorSet) ):
					iPts = 1
				else:
					iPts = 0.20
				explode(v, iPts)
				dCellsMap[v] = '$'
				update()
	timer.set_wait_time(t)
#	timer.connect( "timeout",self,"pieceMoveDown", [true] )	pva
	lbWow.set_hidden( true )


# delete line 'line' or equation and move all lines above to down
# the rows to be deleted must be called from the beginning to the end
func delLine(line, vLine):
	var t = timer.get_wait_time()
	var aux = [ 'GREET_1', 'GREET_2', 'GREET_3' ]
	lbWow.set_pos(vOrigin + Vector2(vUnitSize.x, iHeight*vUnitSize.y/2 + vUnitSize.y) )
	lbWow.set_text( aux[randi() % aux.size()] )
	timer.set_wait_time(0.25)
	if ( bExplodeAll ):
		var iPts = 0.0
		for y in range(int(line),2,-1):
			lbWow.set_hidden( true )
			yield(timer,"timeout")
			update()
			for x in range(iWidth):
#				timer.disconnect("timeout",self,"pieceMoveDown")	pva
				timer.set_wait_time(0.25)
				if ( y == line and dCellsMap[Vector2(x,y)] != ' ' and dCellsMap[Vector2(x,y)] != '$'):
					yield(timer,"timeout")
					if( lbWow.is_hidden() ):
						lbWow.set_hidden( false )
					else:
						lbWow.set_hidden( true )
					if( dCellsMap[Vector2(x,y)].is_subsequence_of(sOperatorSet) ):
						iPts = 1
					else:
						iPts = 0.20
					explode(Vector2(x,y), iPts)
				if(y > 2):
					# if cell(x,y) is not tile map ' ' put '$''
					if ( ! (dCellsMap[Vector2(x,y)] == ' ' or dCellsMap[Vector2(x,y)] == '>' or\
					 								dCellsMap[Vector2(x,y)] == '<' )): 
						dCellsMap[Vector2(x,y)] = '$'
						# if cell(x,y-1) is not a tile map ' ' move it down to cell(x,y) 
						if ( ! ( dCellsMap[Vector2(x,y-1)] == ' ' or dCellsMap[Vector2(x,y-1)] == '>' or\
					 								dCellsMap[Vector2(x,y-1)] == '<' ) ):  
							dCellsMap[Vector2(x,y)] = dCellsMap[Vector2(x,y-1)]
							dCellsMap[Vector2(x,y-1)] = '$'
				# when y is 0, just delete its content except tile map with ' '
				elif(y == 2 and dCellsMap[Vector2(x,y)] != ' '):
					dCellsMap[Vector2(x,y)] = '$'
				update()
	else:
		var iPts = 0.0
		var fAddPts = 2.0/iWidth
		for y in range(int(line),2,-1):
			lbWow.set_hidden( true )
			yield(timer,"timeout")
			update()
			for v in vLine:
#				timer.disconnect("timeout",self,"pieceMoveDown")	pva
				timer.set_wait_time(0.25)
				if ( y == line and dCellsMap[Vector2(v.x,y)] != ' ' and dCellsMap[Vector2(v.x,y)] != '$'):
					yield(timer,"timeout")
					if( lbWow.is_hidden() ):
						lbWow.set_hidden( false )
					else:
						lbWow.set_hidden( true )
					if( dCellsMap[v].is_subsequence_of(sOperatorSet) ):
						iPts = 1
					else:
						iPts = 0.20
					explode(v, iPts)
				if(y > 2):
					# if cell(x,y) is not tile map ' ' put '$''
					if ( ! (dCellsMap[Vector2(v.x,y)] == ' ' or dCellsMap[Vector2(v.x,y)] == '>' or\
					 								dCellsMap[Vector2(v.x,y)] == '<' )): 
						dCellsMap[Vector2(v.x,y)] = '$'
						# if cell(x,y-1) is not a tile map ' ' move it down to cell(x,y) 
						if ( ! ( dCellsMap[Vector2(v.x,y-1)] == ' ' or dCellsMap[Vector2(v.x,y-1)] == '>' or\
					 								dCellsMap[Vector2(v.x,y-1)] == '<' ) ):  
							dCellsMap[Vector2(v.x,y)] = dCellsMap[Vector2(v.x,y-1)]
							dCellsMap[Vector2(v.x,y-1)] = '$'
				# when y is 0, just delete its content except tile map with ' '
				elif(y == 2 and dCellsMap[Vector2(v.x,y)] != ' '):
					dCellsMap[Vector2(v.x,y)] = '$'
				update()
	timer.set_wait_time(t)
#	timer.connect( "timeout",self,"pieceMoveDown", [true] )  pva
	lbWow.set_hidden( true )

func _draw():
	# draw the dCellsMap dictionary
	var charPos = Vector2(vUnitSize.x * 0.375, vUnitSize.y * 0.625)
	for y in range(iHeight):
		for x in range(iWidth):
			if (dCellsMap[Vector2(x, y)] != '$'):
				if( y > 1 and dCellsMap[Vector2(x, y)] != '>' and dCellsMap[Vector2(x, y)] != '<' ):
					draw_texture_rect(oUnitaryBlock, Rect2(Vector2(x, y)*vUnitSize + vOrigin,\
						vUnitSize), false, getColor(dCellsMap[Vector2(x, y)],false))
#					draw_string(preload("res://fonts/titilliumRegular18.fnt"),\
					draw_string(fDynFont,\
						Vector2(x*vUnitSize.x + charPos.x + vOrigin.x, y*vUnitSize.y + charPos.y + vOrigin.y),\
						str(dCellsMap[Vector2(x, y)]), Color(0,0,0) )
				else:
					draw_texture_rect(oUnitaryBlock, Rect2(Vector2(x, y)*vUnitSize + vOrigin,\
						vUnitSize), false, Color(1,1,0.5,0.3))
#					draw_string(preload("res://fonts/titilliumRegular18.fnt"),\
					draw_string(fDynFont,\
						Vector2(x*vUnitSize.x + charPos.x + vOrigin.x, y*vUnitSize.y + charPos.y + vOrigin.y),\
						str(dCellsMap[Vector2(x, y)]), Color(1,1,0) )
					
			elif( y > -1 ):
				draw_texture_rect(oUnitaryBlock, Rect2(Vector2(x, y)*vUnitSize + vOrigin,\
					vUnitSize), false, Color(.5,1,1,0.3))
	if (bHit):
		for av in dResult.values():
			for v in av:
				draw_texture_rect(oUnitaryBlock, Rect2(v*vUnitSize + vOrigin,\
					vUnitSize), false, Color(1,1,1,1))
#				draw_string(preload("res://fonts/titilliumRegular18.fnt"),\
				draw_string(fDynFont,\
					Vector2((v.x * vUnitSize.x )+ charPos.x + vOrigin.x, (v.y * vUnitSize.y) + charPos.y + vOrigin.y),\
					str(dCellsMap[v]), Color(1,0,0,1) )
	# draw the active piece
	if (bPieceActive):
		var i = 0
		for c in avBlockShapes[iPieceShape]:
			draw_texture_rect(oUnitaryBlock, Rect2(vXformTransform(c)*vUnitSize + vOrigin,\
			     vUnitSize), false, getColor(sBlockMath[i], true) )		 # vBlockColors[i]
#			draw_string(preload("res://fonts/titilliumRegular18.fnt"),\
			draw_string(fDynFont,\
				vXformTransform(c)*vUnitSize+Vector2(charPos.x + vOrigin.x,\
				charPos.y + vOrigin.y), sBlockMath[i], Color(0,0,0))
#			draw_string(preload("../assets/titilliumRegular18.fnt"),\
#				vXformTransform(c)*vUnitSize+Vector2(vUnitSize.x-18 + vOrigin.x,\
#				vUnitSize.y-12 + vOrigin.y), sBlockMath[i], Color(0,0,0))
			i+=1

func explode( vPos, iPts, color = Color(1,1,1) ):	
	vPos = ( vPos * vUnitSize ) + vUnitSize/2 + vOrigin	
	get_node("particles").set_pos(vPos)
	get_node("particles").set_color( color )
	get_node("particles").set_emitting(true)
	get_node("particles").set_emit_timeout(0.2)
#	get_node("sounds").play("res://sounds/sound_explode")
	get_node("sounds").play("sound_explode")
	iScore += iPts*iPtos
#	print( 'iPts: ', iPts, ' iPtos: ', iPtos, ' iPts * iPtos= ', iPts * iPtos )
	lbScore.set_text(tr("SCORE") + str(iScore).pad_decimals(0) + ' / 1000')
	# send congratulations
#	if( iPts > 0):
#		var aux = ['W O W !', 'G R E A T !', 'G O O D !']
#		var n = 10
#		var t = timer.get_wait_time()
#		lbWow.set_size( Vector2(50,20) )
#		lbWow.set_pos( get_size() / 2 )
#		lbWow.set_text( aux[randi() % aux.size()] )
#		lbWow.set_scale( Vector2(1,1) )
#		lbWow.set_hidden( false )
#		timer.set_wait_time(0.02)
#		for k in range (n):
#			yield(timer,"timeout")
#			lbWow.set_scale(Vector2(1+k/10.0,1+k/10.0) )			
#			update()
#		lbWow.set_scale( Vector2(1,1) )
#		lbWow.set_hidden( true )
#		timer.set_wait_time(t)

################################ doc and simplify this  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
func fillCellsMapWhenEmpty( iPercent = 10, iStreamsOfOperators = 1 ):
	if( iStreamsOfOperators ):
		var isHorizontal = 1
		var isLeftToWrite = 1
		var iSpace = 1
		var iHowManyOps = 1
		var sStream = ''
		var lengthOfStream = 0
		var iRest = -1
		# fill randomly dCellsMap except the three first lines
		for n in range(iWidth*iHeight*iPercent/100):
			dCellsMap[Vector2(randi()%iWidth, 3+randi()%(iHeight-3))] = getNumber()
		# for each stream randomly all conditions
		for i in range(iStreamsOfOperators):
			isHorizontal = randi() % 2
			isLeftToWrite = randi() % 2
			# 10% of spaces will be single space
			iSpace = randi() % 10
			if( iSpace  ):
				iSpace = 1
			else:
				iSpace = 2
			# 10% of streams will have one operator
			iHowManyOps = randi() % 10
			if( iHowManyOps ):
				iHowManyOps = 1
			else:
				iHowManyOps = 2
			if( sOperatorSet.length() ):
				lengthOfStream = 2 + iHowManyOps + (iHowManyOps-1) + 2*iSpace
			else:
				lengthOfStream = 2 + 2*iSpace
	#		print('lengthOfStream: ', lengthOfStream)
			if( isHorizontal ):
				iRest = iWidth - lengthOfStream
			else:
				iRest = iHeight - 2 - lengthOfStream
			# test if ' (s||ss) = (s||ss) op (s || s op s ) ' fit on grade
			while( iRest < 0 ):
				if( isHorizontal ):
					iRest = iWidth - lengthOfStream
					if( iHowManyOps > 1 ):
						iHowManyOps = 1
						lengthOfStream = 2 + iHowManyOps + (iHowManyOps-1) + 2*iSpace
						continue
					elif( iSpace > 1 ):
						iSpace = 1
						lengthOfStream = 2 + iHowManyOps + (iHowManyOps-1) + 2*iSpace
						continue
					elif( iRest < 0 ):
						print( "The stream don't fit in the width")
						break 
				else:
					iRest = iHeight - lengthOfStream - 2
					if( iHowManyOps > 1 ):
						iHowManyOps = 1
						lengthOfStream = 2 + iHowManyOps + (iHowManyOps-1) + 2*iSpace
						continue
					elif( iSpace > 1 ):
						iSpace = 1
						lengthOfStream = 2 + iHowManyOps + (iHowManyOps-1) + 2*iSpace
						continue
					elif( iRest < 0 ):
						print( "The stream don't fit in the height")
						break 
	#		print('lengthOfStream: ', lengthOfStream)
			# fill the sStream
			if( iSpace == 1):
				sStream = ' =$'
			else:
				sStream = ' $= $'
			if( sOperatorSet.length() ):
				var substr = ''
				if( sOperatorSet.find('(') != -1 ):
					substr = sOperatorSet.substr( 0,sOperatorSet.find('(') )
				else:
					substr = sOperatorSet+''
				if( iHowManyOps == 1 ):
					sStream += substr[randi() % substr.length()] + '$'
				else:
					sStream += substr[randi() % substr.length()] + '$' +\
							   substr[randi() % substr.length()] + '$'
#				print('substr: ',substr)
			else:
				sStream += '$'
			if( ! isLeftToWrite ):
				sStream = invString(sStream)
#			print( 'sStream: ', sStream, ' length: ', sStream.length() )
#			print( 'iRest: ', iRest, ' iSpace: ', iSpace, ' iHowManyOps: ', iHowManyOps)
			var start = 0
			if( iRest ):
				var start = randi() % iRest
#			print(sStream)
			if( isHorizontal and iWidth ):
				var y =  3 + randi() % ( iHeight - 3)
	#			for x in range(iWidth - iRest):
				for x in range( sStream.length() ):
					# do not replace an operator 
					if( (! dCellsMap[Vector2(start + x , y)].is_subsequence_of(sOperatorSet)) and\
					 		sStream[x] != ' '):
	#				if( sStream[x] != ' ' ):
						dCellsMap[Vector2(start + x , y)] = sStream[x]
#						print( sStream[x])
			elif( iWidth ):
				var x = randi() % iWidth
	#			for y in range( iHeight - 2 - iRest):
				for y in range( sStream.length() ):
					if( (! dCellsMap[Vector2( x , y + 2 + iRest)].is_subsequence_of(sOperatorSet)) and\
							sStream[y] != ' '):
	#				if( sStream[x] != ' ' ):
						dCellsMap[Vector2( x , y + 2 + iRest)] = sStream[y]
#						print( sStream[y])
	# for now if iStreamsOfOperators == 0 then set the second configuration of the stage
	else:
		# fill the rows with:
		for x in range( iWidth ):
			if( randi() % 3 and x and ! sOperatorSet.empty()):
				var char = sOperatorSet[ randi() % sOperatorSet.length() ]
				if( char != '(' and char != ')'):
					dCellsMap[Vector2( x , iHeight-5)] = char
					dCellsMap[Vector2( x - 1, iHeight-5)] = '$'				
				if( iHeight > 10 ):
					char = sOperatorSet[ randi() % sOperatorSet.length() ]
					if( char != '(' and char != ')'):
						dCellsMap[Vector2( x , iHeight-7)] = char
						dCellsMap[Vector2( x - 1, iHeight-7)] = '$'
			dCellsMap[Vector2( x, iHeight-3)] = '='
			dCellsMap[Vector2( x, iHeight-2)] = str( randi() % 9 + 1 )
			if( randi() % 4 ):
				dCellsMap[Vector2( x, iHeight-1)] = ' '
			else:
				dCellsMap[Vector2( x, iHeight-1)] = str( randi() % 10 )


func gameOver():
	bPieceActive = false
	get_node("AcceptDialog").set_text("Game Over!")
	get_node("AcceptDialog").set_pos(Vector2(iWidth/2,iHeight/2))
	get_node("AcceptDialog").set_hidden(false)
#	dCellsMap.clear()
#	update()


####### redo it after put multiple stages
# return char from sNumberSet with adequate balance
func getNumber():
	return sNumberSet[randi() % sNumberSet.length()]

# return randomly sOperatorSet except the 0 position or '=' 
func getOperator():
	return sOperatorSet[ 1 + randi() % ( sOperatorSet.length()-1 ) ] 

func getColor(char, isActive):	# ok
	var a = 0.9
	if(isActive):
		a = 1
#	var colors = [
#	[0.7,1.0,1.0,a],
#	[0.8,1.0,1.0,a],
#	[0.9,1.0,1.0,a],
#	[1.0,0.9,1.0,a],
#	[1.0,0.8,1.0,a],
#	[1.0,0.7,1.0,a],
#	[1.0,0.8,0.9,a],
#	[1.0,0.9,0.8,a],
#	[1.0,1.0,0.7,a],
#	[0.9,1.0,0.8,a],
#	]
#	var colors = [
#	[1,1,0,a],
#	[0.9,1,0.2,a],
#	[0.8,1,0.3,a],
#	[0.7,1,0.4,a],
#	[0.6,1,0.5,a],
#	[0.5,1,0.6,a],
#	[0.4,1,0.7,a],
#	[0.3,1,0.8,a],
#	[0.2,1,0.9,a],
#	[0,1,1,a],
#	]
	var colors = [
	[1.0,1.0,0.0,a],
	[0.8,1.0,0.0,a],
	[0.6,1.0,0.0,a],
	[0.0,1.0,0.8,a],
	[0.0,1.0,1.0,a],
	[0.0,0.8,1.0,a],
	[0.0,0.6,1.0,a],
	[0.6,0.4,1.0,a],
	[0.8,0.0,1.0,a],
	[1.0,0.0,1.0,a],
	]
	if( char == '='):
		return Color(1,1,1,a)
	elif( char == '+'):
		return Color(0,1,0.5,a)
	elif( char == '-'):
		return Color(0.4,1,0.7,a)
	elif( char == '*'):
		return Color(0.2,0.9,0.9,a)
	elif( char == ' ' ):
		return Color(1,1,1,0)
	elif ( char == '<' ):
		return Color(.5,1,1,0.3)
#		return Color(1,.1,0,a)
	elif ( char == '>' ):
		return Color(.5,1,1,0.3)
#		return Color(1,1,0,a)
	elif( char.is_valid_integer()):
		return Color(colors[int(char)][0],colors[int(char)][1],colors[int(char)][2],colors[0][3])
	else:
		return Color(0.0,0.7,1.0,a)
		
func _input(ie):
	var vPos = Vector2()
	var vViewPort = get_viewport_rect().size
	if (not bPieceActive):
		return
	if (!( ie.is_pressed() or ie.type==InputEvent.MOUSE_BUTTON) ):
		return
	if ( ie.type==InputEvent.MOUSE_BUTTON ):
		vPos = ie.pos
		
	print("Viewport resolution: ", get_viewport_rect().size)
	print("vPiecePosition: ", vPiecePosition)
	print("vOrigin: ", vOrigin)
	print("vUnitSize: ", vUnitSize)
	# do nothing when on line one
	if ((ie.is_action("moveLeft") and vPiecePosition.y != 1) or \
		(ie.type==InputEvent.MOUSE_BUTTON and ie.pressed and vPos.x < vViewPort.x/4 and \
		vPos.y > vViewPort.y/6 and vPos.y < vViewPort.y*5/6)  ):
		if (bCheckFit(Vector2(-1, 0))):
			vPiecePosition.x -= 1
			vDispl = Vector2(-1,0)
			update()
		# do not load dCellsMap on line zero
		elif( vPiecePosition.y != 0 ):
			get_node("sounds").play("sound_shoot")
			var i = 0
			for cell in avBlockShapes[iPieceShape]:
				var pos = vXformTransform(cell)
				dCellsMap[pos] = sBlockMath[i]
				i+=1
			hitDict(checkHit())
			newPiece()
	# do nothing when on line one
	elif ((ie.is_action("moveRight") and vPiecePosition.y != 1) or \
		(ie.type == InputEvent.MOUSE_BUTTON and ie.pressed and vPos.x > vViewPort.x*3/4 and \
		vPos.y > vViewPort.y/6 and vPos.y < vViewPort.y*5/6)  ):
		if (bCheckFit(Vector2(1, 0))):
			vPiecePosition.x += 1
			vDispl = Vector2(1,0)
			update()
		# do not load dCellsMap on line zero
		elif( vPiecePosition.y != 0 ):
			get_node("sounds").play("sound_shoot")
			var i = 0
			for cell in avBlockShapes[iPieceShape]:
				var pos = vXformTransform(cell)
				dCellsMap[pos] = sBlockMath[i]
				i+=1
			hitDict(checkHit())
			newPiece()
	elif (ie.is_action("moveDown") or \
		(ie.type == InputEvent.MOUSE_BUTTON and ie.pressed and vPos.x >= vViewPort.x/4 and vPos.x <= vViewPort.x*3/4 and \
		vPos.y > vViewPort.y/6 and vPos.y < vViewPort.y*5/6)  ):
		pieceMoveDown(false)
	elif ( ie.is_action("rotate") and vPiecePosition.y > 1 ):
		pieceRotate()
	elif ( (ie.is_action("rotate") and vPiecePosition.y == 0) or \
		(ie.type == InputEvent.MOUSE_BUTTON and ie.pressed and vPos.x >= vViewPort.x/4 and vPos.x <= vViewPort.x*3/4 and \
		 vPos.y > vViewPort.y*5/6) ):
		explodeLastAndContatctCells()
	elif (ie.is_action("explode") or \
		(ie.type == InputEvent.MOUSE_BUTTON and ie.pressed and vPos.x >= vViewPort.x/4 and vPos.x <= vViewPort.x*3/4 and \
		vPos.y < vViewPort.y/6 )):
		pieceExplode()
	elif (ie.is_action("fallOrNot")):
		_on_btPause_pressed()

func explodeLastAndContatctCells():
		if(  dCellsMap[vLastCell] != '$' ):  # vLastCell != null and
			explode( vLastCell, -1, Color(1,0,0) )
			dCellsMap[vLastCell] = '$'
		timer.set_wait_time(0.25)
		yield(timer,"timeout")
		if(  dCellsMap[vContactCell] != '$' ): # vContactCell != null and
			explode( vContactCell, -1, Color(1,0,0) )
			dCellsMap[vContactCell] = '$'
	
func newPiece():
	iPieceShape = randi() % iMaxShapes
	sBlockMath = ''
	vBlockColors.clear()
	for i in range(avBlockShapes[iPieceShape].size()):
		sBlockMath += getNumber()  
		vBlockColors.append(getColor(sBlockMath[i],true))
	vPiecePosition = Vector2(0, 0)
	bPieceActive = true
	vDispl = Vector2(1,0)
	iPieceRotate = 0	
	if (! bCheckFit(Vector2())):
		gameOver()
	update()

func _on_btPause_pressed():
	if(bOnPause):
		bOnPause = false
		get_node("../btPause").set_text(tr("PAUSE"))
		timer.start()
	else:
		bOnPause = true
		get_node("../btPause").set_text(tr("MOVE"))
		timer.stop()
		
func _on_btLanguage_item_selected( ID ):
	if( ID == 0 ):
		TranslationServer.set_locale("en")
	elif ( ID == 1 ):
		TranslationServer.set_locale("pt")
	else:
		TranslationServer.set_locale("en")

func _on_btRestart_pressed():
	var comm = get_node("../commands")
	var next = get_node("../btNext")
	var prev = get_node("../btPrev") 
	var pause = get_node("../btPause")
	var test = get_node("scoreTest").get_text()
	timer.start()
	setupStage()
#	update()
	if( ! comm.is_hidden() ):
		pause.set_hidden(false)
		pause.set_opacity(0)
		self.set_opacity(0)
		timer.set_wait_time(0.1)
		for i in range(100,0,-5):
			yield( timer, "timeout" )
			comm.set_opacity(i/100.0)
#			next.set_opacity(i/100.0)
#			prev.set_opacity(i/100.0)
			btLanguage.set_opacity(i/100.0)
#			lbStage.set_opacity(i/100.0)
			self.set_opacity(1-i/100.0)
			pause.set_opacity(1-i/100.0)
			update()
	#		comm.set_size( Vector2(i*3,i*3) )
		comm.set_hidden(true)
		btLanguage.set_hidden( true )
#	get_node("../commands").set_hidden(true)
	if( test != ''):
		iScore = int(test)
	lbScore.set_text(tr("SCORE") + str(iScore) + ' / 1000')
#	setupStage()
	bPieceActive = true
	bOnPause = true
	_on_btPause_pressed()
	get_node("../btRestart").release_focus()
	get_node("../btRestart").set_text(tr("RESTART"))
	newPiece()


func _on_btNext_pressed():
	iStage += 1
	if( iStage > 13 ):
		iStage = 13
	lbStage.set_text( tr("STAGE_"+str(iStage)) )

func _on_scoreTest_focus_enter():
	get_node("scoreTest").clear()

func _on_scoreTest_text_changed( text ):
	iScore = int(text)
	lbScore.set_text(tr("SCORE") + str(iScore).pad_decimals(0) + ' / 1000')

func _on_stageTest_text_changed( text ):
	iStage = int(text)
	
func _on_btPrev_pressed():
	iStage -= 1
	if( iStage == 0 ):
		iStage = 1
	lbStage.set_text(tr("STAGE_" + str(iStage)) )

# explode an active piece
func pieceExplode():
	if ( ! bPieceActive):
		return
	var t = timer.get_wait_time()
	timer.set_wait_time(0.25)
	for c in avBlockShapes[iPieceShape]:
		explode( vXformTransform(c), -1, Color(1,0,0) )		
		yield(timer,"timeout")
	timer.set_wait_time(t)
	newPiece()
	

func pieceMoveDown(isFromClock):
	if( isFromClock ):
		checkIfCellsMapIsEmpty( )
	var aux 
	if ( ! bPieceActive):
		return
	timer.set_wait_time(0.75)
	# use the horizontal displacement on line 0
	if ( vPiecePosition.y == 0 and isFromClock ): 
#		update()
		yield(timer,"timeout")
#		print( bCheckFit(vDispl) )
		if( bCheckFit(vDispl) ):
			vPiecePosition += vDispl
		else:
			if( vDispl.x == 1 ):
				vDispl.x = -1
			else:
				vDispl.x = 1
#			bCheckFit(vDispl)
			vPiecePosition += vDispl
		update()
	# check and down displacement
	elif ( vPiecePosition.y == 1 and  isFromClock ): 
		pass
	elif (bCheckFit(Vector2(0, 1))):
		vDispl = Vector2(0,1)
		vPiecePosition += vDispl
		update()
	else:
		get_node("sounds").play("sound_shoot")
		var i = 0
		for cell in avBlockShapes[iPieceShape]:
			var pos = vXformTransform(cell)
			dCellsMap[pos] = sBlockMath[i]
			i+=1
		hitDict(checkHit())
		newPiece()

func pieceRotate():
	if (! bCheckFit(Vector2(), 1)):
		return
	var advance = 1
	iPieceRotate = (iPieceRotate + advance) % 4
	update()

func _ready():
	seed(OS.get_system_time_secs())
	randomize()
	# set dynamic font to _draw
	fDynFontData.set_font_path("./fonts/Lato-Regular.ttf")
	fDynFont.set_font_data(fDynFontData)
	fDynFont.set_size(18)
#	get_node("../../mathWorld").Translation.set_locale("pt_BR")
	btLanguage = get_node("../btLanguage")
	btLanguage.add_item("English")
	btLanguage.add_item("Português")
	_on_btLanguage_item_selected(0)
#	TranslationServer.set_locale("pt")
	lbStage = get_node("../lbStage")
	lbStage.set_text( tr("STAGE_"+str(iStage)) )
	lbWow = get_node("lbWow")
	lbScore = get_node("../lbScore")
	timer = get_node("timer")
	timer.set_wait_time(0.75)
#	timer.start()
	timer.connect("timeout",self,"pieceMoveDown", [true])
	get_node("../btRestart").set_text(tr("START"))
	get_node("../notes").set_bbcode(tr('NOTES_0'))
	set_process_input(checkLock())

# setup game stages->
# 1:=, 2:roman, 3:+, 4:-, 5:+-, 6:*, 7:/, 8:/f 9:%, 10:+-*, 11:+-*(), 
# 12: +-*/(), 13: +-*/%()

func setupStage():
	if ( iStage == 1 ):
		sOperatorSet = ''
		sNumberSet = '0123456789'
		iWidth = 5
		iHeight = 8
		iMaxShapes = 1
		iPtos = 50  # set to round value when is multiply by 0.2
		vUnitSize = Vector2(44,44)
		# centralized the game
		vOrigin = Vector2( get_viewport_rect().size.x / 2 - iWidth * vUnitSize.x / 2, 2*get_viewport_rect().size.y / 5 - iHeight * vUnitSize.y / 2 )
		vStartPos = Vector2(0,0)
		get_node("../lbScore").set_pos(Vector2(vOrigin.x,vOrigin.y-2*vUnitSize.y))		
		dIni = { 
			Vector2(0,1) : '=', Vector2(2,1) : '>', Vector2(4,1) : '<'
		}
		get_node("../notes").set_bbcode(tr('NOTES_1'))
	# roman algarism for two digits compare
	elif ( iStage == 2 ):
		sOperatorSet = ''
		sNumberSet = '0123456789IVX'
		iWidth = 10
		iHeight = 10
		iMaxShapes = 1
		iPtos = 50  # set to round value when is multiply by 0.2
		vUnitSize = Vector2(44,44)
		# centralized the game
		vOrigin = Vector2( get_viewport_rect().size.x / 2 - iWidth * vUnitSize.x / 2, 2*get_viewport_rect().size.y / 5 - iHeight * vUnitSize.y / 2 )
		vStartPos = Vector2(0,0)
		get_node("../lbScore").set_pos(Vector2(vOrigin.x,vOrigin.y-2*vUnitSize.y))		
		dIni = { 
			Vector2(3,0) : '>', Vector2(7,0) : '<',
			Vector2(0,1) : '=', Vector2(2,1) : 'I', Vector2(3,1) : 'V', Vector2(4,1) : 'X',
			Vector2(6,1) : 'L', Vector2(7,1) : 'C', Vector2(8,1) : 'D', Vector2(9,1) : 'M'
		}
		get_node("../notes").set_bbcode(tr('NOTES_2'))
	elif ( iStage == 3 ):
		sOperatorSet = '+'
		sNumberSet = '0123456789'
		iWidth = 7
		iHeight = 9
		iMaxShapes = 12
		iPtos = 50  # set to round value when is multiply by 0.2
		vUnitSize = Vector2(38,38)
		# centralized the game
		vOrigin = Vector2( get_viewport_rect().size.x / 2 - iWidth * vUnitSize.x / 2, 2*get_viewport_rect().size.y / 5 - iHeight * vUnitSize.y / 2 )
		vStartPos = Vector2(0,0)
		get_node("../lbScore").set_pos(Vector2(vOrigin.x,vOrigin.y-2*vUnitSize.y))
		dIni = { 
			Vector2(0,1) : '=', Vector2(2,1) : '+', Vector2(4,1) : '>', Vector2(6,1) : '<'
		}
		get_node("../notes").set_bbcode(tr('NOTES_3'))
	elif ( iStage == 4 ):
		sOperatorSet = '-'
		sNumberSet = '0123456789'
		iWidth = 7
		iHeight = 9
		iMaxShapes = 12
		iPtos = 50  # set to round value when is multiply by 0.2
		vUnitSize = Vector2(38,38)
		# centralized the game
		vOrigin = Vector2( get_viewport_rect().size.x / 2 - iWidth * vUnitSize.x / 2, 2*get_viewport_rect().size.y / 5 - iHeight * vUnitSize.y / 2 )
		vStartPos = Vector2(0,0)
		get_node("../lbScore").set_pos(Vector2(vOrigin.x,vOrigin.y-2*vUnitSize.y))
		dIni = { 
			Vector2(0,1) : '=', Vector2(2,1) : '-', Vector2(4,1) : '>', Vector2(6,1) : '<'
		}
		get_node("../notes").set_bbcode(tr('NOTES_4'))
	elif ( iStage == 5 ):
		sOperatorSet = '+-'
		sNumberSet = '0123456789'
		iWidth = 9
		iHeight = 11
		iMaxShapes = 13
		iPtos = 50  # set to round value when is multiply by 0.2
		vUnitSize = Vector2(38,38)
		# centralized the game
		vOrigin = Vector2( get_viewport_rect().size.x / 2 - iWidth * vUnitSize.x / 2, 2*get_viewport_rect().size.y / 5 - iHeight * vUnitSize.y / 2 )
		vStartPos = Vector2(0,0)
		get_node("../lbScore").set_pos(Vector2(vOrigin.x,vOrigin.y-2*vUnitSize.y))
		dIni = { 
			Vector2(0,1) : '=', Vector2(2,1) : '+',Vector2(4,1) : '-', Vector2(6,1) : '>', Vector2(8,1) : '<'
		}
		get_node("../notes").set_bbcode(tr('NOTES_5'))
	elif ( iStage == 6 ):
		sOperatorSet = '*'
		sNumberSet = '0123456789'
		iWidth = 7
		iHeight = 9
		iMaxShapes = 12
		iPtos = 50  # set to round value when is multiply by 0.2
		vUnitSize = Vector2(38,38)
		# centralized the game
		vOrigin = Vector2( get_viewport_rect().size.x / 2 - iWidth * vUnitSize.x / 2, 2*get_viewport_rect().size.y / 5 - iHeight * vUnitSize.y / 2 )
		vStartPos = Vector2(0,0)
		get_node("../lbScore").set_pos(Vector2(vOrigin.x,vOrigin.y-2*vUnitSize.y))
		dIni = { 
			Vector2(0,1) : '=', Vector2(2,1) : '*', Vector2(4,1) : '>', Vector2(6,1) : '<'
		}
		get_node("../notes").set_bbcode(tr('NOTES_6'))
	elif ( iStage == 7 ):
		sOperatorSet = '/'
		sNumberSet = '0123456789'
		iWidth = 7
		iHeight = 9
		iMaxShapes = 12
		iPtos = 50  # set to round value when is multiply by 0.2
		vUnitSize = Vector2(38,38)
		# centralized the game
		vOrigin = Vector2( get_viewport_rect().size.x / 2 - iWidth * vUnitSize.x / 2, 2*get_viewport_rect().size.y / 5 - iHeight * vUnitSize.y / 2 )
		vStartPos = Vector2(0,0)
		get_node("../lbScore").set_pos(Vector2(vOrigin.x,vOrigin.y-2*vUnitSize.y))
		dIni = { 
			Vector2(0,1) : '=', Vector2(2,1) : '/', Vector2(4,1) : '>', Vector2(6,1) : '<'
		}
		get_node("../notes").set_bbcode(tr('NOTES_7'))
	elif ( iStage == 8 ):
		sOperatorSet = '/'
		sNumberSet = '0123456789'
		iWidth = 7
		iHeight = 9
		iMaxShapes = 12
		iPtos = 50  # set to round value when is multiply by 0.2
		vUnitSize = Vector2(38,38)
		# centralized the game
		vOrigin = Vector2( get_viewport_rect().size.x / 2 - iWidth * vUnitSize.x / 2, 2*get_viewport_rect().size.y / 5 - iHeight * vUnitSize.y / 2 )
		vStartPos = Vector2(0,0)
		get_node("../lbScore").set_pos(Vector2(vOrigin.x,vOrigin.y-2*vUnitSize.y))
		dIni = { 
			Vector2(0,1) : '=', Vector2(2,1) : '/', Vector2(4,1) : '>', Vector2(6,1) : '<'
		}
		get_node("../notes").set_bbcode(tr('NOTES_8'))
	elif ( iStage == 9 ):
		sOperatorSet = '%'
		sNumberSet = '0123456789'
		iWidth = 7
		iHeight = 9
		iMaxShapes = 12
		iPtos = 50  # set to round value when is multiply by 0.2
		vUnitSize = Vector2(38,38)
		# centralized the game
		vOrigin = Vector2( get_viewport_rect().size.x / 2 - iWidth * vUnitSize.x / 2, 2*get_viewport_rect().size.y / 5 - iHeight * vUnitSize.y / 2 )
		vStartPos = Vector2(0,0)
		get_node("../lbScore").set_pos(Vector2(vOrigin.x,vOrigin.y-2*vUnitSize.y))
		dIni = { 
			Vector2(0,1) : '=', Vector2(2,1) : '%', Vector2(4,1) : '>', Vector2(6,1) : '<'
		}
		get_node("../notes").set_bbcode(tr('NOTES_9'))
	elif ( iStage == 10 ):
		sOperatorSet = '+-*'
		sNumberSet = '0123456789'
		iWidth = 11
		iHeight = 11
		iMaxShapes = 13
		iPtos = 50  # set to round value when is multiply by 0.2
		vUnitSize = Vector2(32,32)
		# centralized the game
		vOrigin = Vector2( get_viewport_rect().size.x / 2 - iWidth * vUnitSize.x / 2, 2*get_viewport_rect().size.y / 5 - iHeight * vUnitSize.y / 2 )
		vStartPos = Vector2(0,0)
		get_node("../lbScore").set_pos(Vector2(vOrigin.x,vOrigin.y-2*vUnitSize.y))
		dIni = { 
			Vector2(0,1) : '=', Vector2(2,1) : '+',Vector2(4,1) : '-', Vector2(6,1) : '*',Vector2(8,1) : '>', Vector2(10,1) : '<'
		}
		get_node("../notes").set_bbcode(tr('NOTES_10'))
	elif ( iStage == 11 ):
		sOperatorSet = '+-*()'
		sNumberSet = '0123456789'
		iWidth = 13
		iHeight = 13
		iMaxShapes = 13
		iPtos = 50  # set to round value when is multiply by 0.2
		vUnitSize = Vector2(32,32)
		# centralized the game
		vOrigin = Vector2( get_viewport_rect().size.x / 2 - iWidth * vUnitSize.x / 2, 2*get_viewport_rect().size.y / 5 - iHeight * vUnitSize.y / 2 )
		vStartPos = Vector2(0,0)
		get_node("../lbScore").set_pos(Vector2(vOrigin.x,vOrigin.y-2*vUnitSize.y))
		dIni = { 
			Vector2(0,1) : '=', Vector2(2,1) : '+',Vector2(4,1) : '-', Vector2(6,1) : '*',Vector2(8,1) : '>', Vector2(9,1) : '<',Vector2(11,1) : '(', Vector2(12,1) : ')'
		}
		get_node("../notes").set_bbcode(tr('NOTES_11'))
	elif ( iStage == 12 ):
		sOperatorSet = '+-*/()'
		sNumberSet = '0123456789'
		iWidth = 13
		iHeight = 13
		iMaxShapes = 13
		iPtos = 50  # set to round value when is multiply by 0.2
		vUnitSize = Vector2(32,32)
		# centralized the game
		vOrigin = Vector2( get_viewport_rect().size.x / 2 - iWidth * vUnitSize.x / 2, 2*get_viewport_rect().size.y / 5 - iHeight * vUnitSize.y / 2 )
		vStartPos = Vector2(0,0)
		get_node("../lbScore").set_pos(Vector2(vOrigin.x,vOrigin.y-2*vUnitSize.y))
		dIni = { 
			Vector2(0,1) : '=', Vector2(2,1) : '+',Vector2(3,1) : '-', Vector2(5,1) : '*',Vector2(6,1) : '/',Vector2(8,1) : '>', Vector2(9,1) : '<',Vector2(11,1) : '(', Vector2(12,1) : ')'
		}
		get_node("../notes").set_bbcode(tr('NOTES_12'))
	elif ( iStage == 13 ):
		sOperatorSet = '+-*/%()'
		sNumberSet = '0123456789'
		iWidth = 13
		iHeight = 13
		iMaxShapes = 13
		iPtos = 50  # set to round value when is multiply by 0.2
		vUnitSize = Vector2(32,32)
		# centralized the game
		vOrigin = Vector2( get_viewport_rect().size.x / 2 - iWidth * vUnitSize.x / 2, 2*get_viewport_rect().size.y / 5 - iHeight * vUnitSize.y / 2 )
		vStartPos = Vector2(0,0)
		get_node("../lbScore").set_pos(Vector2(vOrigin.x,vOrigin.y-2*vUnitSize.y))
		dIni = { 
			Vector2(0,1) : '=', Vector2(1,1) : '+',Vector2(2,1) : '-', Vector2(4,1) : '*',Vector2(5,1) : '/',Vector2(6,1) : '%',Vector2(8,1) : '>', Vector2(9,1) : '<',Vector2(11,1) : '(', Vector2(12,1) : ')'
		}
		get_node("../notes").set_bbcode(tr('NOTES_13'))
	# after ifs Steps:
	self.set_size(Vector2(iWidth, iHeight)*vUnitSize)
	dCellsMap.clear()	
	# fill dCellsMap with empaty '$' and inis dictonaries
	for y in range(iHeight):
		for x in range(iWidth):
			dCellsMap[Vector2(x,y)] = '$'
			if ( dIni.has(Vector2(x,y)) ):
				dCellsMap[Vector2(x,y)] = dIni[Vector2(x,y)]

func vXformTransform(vc2CellInBlockShapes, iExtraRotate = 0):
	var r = ( iExtraRotate + iPieceRotate) % 4
#	print('Return vXformTransform: ', vPiecePosition + amvBlockRotations[r].xform(vc2CellInBlockShapes))
	return vPiecePosition + amvBlockRotations[r].xform(vc2CellInBlockShapes)


# --------------------------------------------   Algorithms ------------------------------------------------------

# transform strings algorithm in a gd or c++ class ??????

# return a dictonary (dResult) where key are rows (>=0) and columns (<0) with vector of Vectors2(x,y) of the hit results
func checkHit():
	var a = 0
	var b = 0
	var sAux
	var aAux = []
	var asAux = []
	var aavAux = []
	var aavDef = []
	var map = {}
	var h = iHeight
	var w = iWidth
	dResult.clear()
	# check and setup variables for row or collumn
	for isRow in [true,false]:
		if ( isRow ):
			# copy dCellsMap to map
			for y in range(iHeight):
				for x in range(iWidth):
					map[Vector2(x,y)] = dCellsMap[Vector2(x,y)]
			h = iHeight
			w = iWidth
			a = 2
			b = 0
		else:
			# transpose dCellsMap to map
			map.clear()
			for y in range(iHeight):
				for x in range(iWidth):
					map[Vector2(y,x)] = dCellsMap[Vector2(x,y)]
			# invert order
			h = iWidth
			w = iHeight
			a = 0
			b = 2
		# build a array of strings (asAux) which its contents with valid integers and operators separated by '='
		# and build the correspondent array the vectors2 with x,y position in dCellsMap including '=' postion
		for y in range(a, h):
			sAux = ''
			aAux.clear()
			asAux.clear()
			aavAux.clear()
			for x in range(b, w):
				if ( map[Vector2(x,y)] == '=' ):
					if ( x > 0 ):
						# if on sequence of two '=' put a empty string/vector to separate informations
						if ( map[Vector2(x-1,y)] == '=' ):
							asAux.append('')
							aavAux.append([])
							continue
						# if the last char before '=' is the '+' or '-', delete it append sAux, aAux with 
						#	a empty string/vector to separate informations
						if ( map[Vector2(x-1,y)] == '+' or map[Vector2(x-1,y)] == '-' ):
							sAux.erase(sAux.length()-1,1)
							aAux.remove(aAux.size()-1)
							asAux.append(sAux)
							aavAux.append([] + aAux)
							asAux.append('')
							aavAux.append([])
							sAux = ''
							aAux.clear()
							continue
					# append string sAux but not '='
					if ( sAux != ''):
						asAux.append(sAux)
						aavAux.append([] + aAux)
						sAux = ''
						aAux.clear()
				elif ( map[Vector2(x,y)] == '$' or map[Vector2(x,y)] == ' ' or map[Vector2(x,y)] == '<' or map[Vector2(x,y)] == '>' ):
					# appends string sAux, if exists, to asAux when find a '$' or ' '
					if ( sAux != ''):
						asAux.append(sAux)
						aavAux.append([] + aAux)
						sAux = ''
						aAux.clear()
					# put a empty string to separate 
					asAux.append('')
					aavAux.append([])
				else:
					# if it is not '=' or '$' or ' ' load sAux and append aavAux
					sAux += map[Vector2(x,y)]
					aAux.append(Vector2(x,y))
			# at the end of x search if exists sAux append it
			if (sAux != '' ):
				if ( map[Vector2(w-1,y)] == '+' or map[Vector2(w-1,y)] == '-' ):
							sAux.erase(sAux.length()-1,1)
							aAux.remove(aAux.size()-1)
							asAux.append(sAux)
							aavAux.append([] + aAux)
				else:
					asAux.append(sAux)
					aavAux.append([] + aAux)
#			print ( asAux )
			# scanning asAux where asAxu[i] are strings of the math expression
			aavDef.clear()
			for i in range(0,asAux.size()-1):
				if (asAux.size() > 0 ):
					# if not of two strings are null
					if (! (asAux[i] == '' or asAux[i+1] == '') ):
						# check hit between asAux strings
#						if (iGetResult(asAux[i]) == iGetResult(asAux[i+1])):
#						if (evaluate(asAux[i]) == evaluate(asAux[i+1])):
						if (iStage != 2 and eval(asAux[i]) == eval(asAux[i+1]) and eval(asAux[i]) != null ):
							# put in vectors Def only vectors positions of equations hit
							aavDef.append(aavAux[i])
							aavDef.append(aavAux[i+1])
							# adds a Vector2 in aavAux one position after the last Vector2 in aavAux[i]
							var j = aavDef.size() - 2
							var a = []
							a.append(Vector2(aavDef[j][0].x + aavDef[j].size(),y))
							# insert ´=' position betwen vectors
							aavDef.insert(j+1,[]+a)
							a.clear()
						if (iStage == 2 and eval(asAux[i]) == eval(asAux[i+1]) and eval(asAux[i]) != null ):
							if( (isValidRoman(asAux[i]) and isValidString(asAux[i+1])) \
							or (isValidRoman(asAux[i+1]) and isValidString(asAux[i])) ):
								# put in vectors Def only vectors positions of equations hit
								aavDef.append(aavAux[i])
								aavDef.append(aavAux[i+1])
								# adds a Vector2 in aavAux one position after the last Vector2 in aavAux[i]
								var j = aavDef.size() - 2
								var a = []
								a.append(Vector2(aavDef[j][0].x + aavDef[j].size(),y))
								# insert ´=' position betwen vectors
								aavDef.insert(j+1,[]+a)
								a.clear()
				# build 'aux' copied from aavAux without inner vectors and repetitons
				var avAux = []
				var avAuxVert = []
				avAux.clear()
				avAuxVert.clear()
				# remove inner vectors in aavDef and append it in avAux
				for vec in aavDef:
					for v2 in vec:
						avAux.append(v2)
				# delete the repetitons
				for i in range(avAux.size()-2,-1,-1):
					if ( avAux[i] == avAux[i+1] ):
						avAux.remove(i+1)
				# put avAux in dResult 0 to n to rows and -1 to -n-1 to columns
				if ( ! avAux.empty() ):
					if (isRow):
						dResult[y] = [] + avAux
					else:
						for v in avAux:
							avAuxVert.append(Vector2(y,v.x))
							dResult[-y-1] = [] + avAuxVert
#	print ( 'dResul: ', dResult )
	return dResult

func eval( string):
	if ( isValidString(string) ):
		return solveRpn( sRpn( string ) ) 
	elif( isValidRoman(string) ):
		return solveRoman( string )
	else:
		print( 'Invalid expression: ', string )
		return null

# study this function, refactor, clean and comment it
func hitDict( dHit ):
#	printDict(dCellsMap, iHeight, iWidth)
	if ( dHit.empty() ):
		return
	var t = timer.get_wait_time()
#	timer.disconnect( "timeout",self,"pieceMoveDown" )	pva	
	for i in dHit.keys() :
		timer.set_wait_time(0.25)
		# do the dResult in dCellsMap blinks before it explodes
		for v in dHit[i]:
			yield(timer,"timeout")
			if ( bHit ):
				bHit = false 
			else:
				bHit = true
			update()
		# call delLine that dell line 'i' on dCellsMap and move all others cells to down
		if ( i >= 0 ):
			delLine(i, dHit[i])
		else:
			delColumn(i, dHit[i])
	bHit = false
	timer.set_wait_time(t)
#	timer.connect( "timeout",self,"pieceMoveDown", [true] )   pva

func iGetResult(s):
	var res = 0
	var sAux = ''
	for i in range(s.length()):
		sAux += str(s[i])
		if (! sAux.is_valid_integer()):
			# sum sAux except the last char
			res += int(sAux.substr(0,sAux.length()-1))
			# set sAux with the last char
			sAux = sAux.substr(sAux.length()-1,1)
	if ( sAux != '+' or sAux != '-' ):
		res += int(sAux)
	return res

func invString(stringToInvert):
	var stringInverted = ''
	for i in range(stringToInvert.length()-1,-1,-1):
		stringInverted += stringToInvert[i]
	return stringInverted

func isValidRoman( string ):
	var s = ''
	var aux = ''
	for s in string:
		if(! s.is_subsequence_of('IVXLCDM') ):
			return false 
		# limit roman algarisms to sequence of three equals numbers
		if( aux.substr(aux.length()-1,1) == s ):
			aux += s
		else:
			aux = s
		if( aux.length() > 3 ):
			return false
	return true

func isValidString( string ):
	# the order in sOk is infexible, the operators must be greater then 12# position
	var sOk = '0123456789 ()+-*/%'	
	var amountOfNumber = 0
	var iCountLeft = 0
	var iCountRight = 0
	if ( string.empty() ):
		return false
	if ( string.begins_with('*') or string.begins_with(')') or string.begins_with('/') or string.begins_with('%')   ):
		return false
	if ( string.ends_with('*') or string.ends_with('(') or string.begins_with('/') or string.begins_with('%')  ):
		return false
	for s in range(string.length()):
#		print( string[s] )
#		print (sOk.find(string[s]) )
		# check if all values are on the set sOk
		if ( sOk.find( string[s] ) == -1 ):
#			print ('Is not permited: ', string[s], ' on position: ',s )
			return false
		# count numbers
		if ( string[s].is_valid_integer() ):
			amountOfNumber += 1
		# check if there is correct order and number of pharentesis
		if ( string[s] == '(' ):
			iCountLeft += 1
		if ( string[s] == ')' ):
			iCountRight += 1
		# if empty pharentesis return false
		if ( string[s] == '(' and string[s] == ')' ):
			return false
		# at any time in expression the number of ')' must be minor or equal then '('
		if ( iCountRight > iCountLeft ):
			return false
	for s in range(string.length() - 1):
		# checks if there is two operators consecutives
		if ( sOk.find(string[s]) > 12 and sOk.find(string[s+1]) > 12 ):
			return false
	# at the end of expression the number of pharentesis must be equal
	if ( iCountLeft != iCountRight ):
		return false
	# if there is not numbers
	if ( amountOfNumber == 0):
		return false
	return true

func printDict(map,h,w):
	var vect = []
	for y in range(h):
		for x in range(w):
			if ( Vector2(x,y) in map):
				vect.append(map[Vector2(x,y)])
		print(vect)
		vect.clear()

func solveRoman( string ):
	var romanSet = { 'I' : 1, 'V' : 5, 'X' : 10, 'L' : 50, 'C' : 100, 'D' : 500, 'M' : 1000 }
	var decimal = 0
	for i in range( string.length()-1 ):
		if( romanSet[string[i]] >= romanSet[string[i+1]]  ):
			decimal += romanSet[string[i]]
		else:
			decimal -= romanSet[string[i]]
	decimal += romanSet[ string.substr(string.length()-1,1) ]
	return decimal

func solveRpn ( strRpn ):
	var aux = 0
	var stack = []
	var aRpn = strRpn.split(' ', false)
#	print( aRpn )
	for i in range( aRpn.size() ):
		if( aRpn[i].is_valid_integer() ):
			stack.push_front( aRpn[i] )
		# the minor signal '-' is acoplated at number
		elif( stack.size() > 1 ):
			if( aRpn[i] == '+' ):
				aux = int(stack[1]) + int(stack[0])
				stack.pop_front()
				stack.pop_front()
				stack.push_front( aux )
			elif( aRpn[i] == '-' ):
				aux = int(stack[1]) - int(stack[0])
				stack.pop_front()
				stack.pop_front()
				stack.push_front( aux )
			elif( aRpn[i] == '*'):
				aux = int(stack[1]) * int(stack[0])
				stack.pop_front()
				stack.pop_front()
				stack.push_front( aux )
			elif( aRpn[i] == '/'):
				aux = int(stack[1]) / int(stack[0])
				stack.pop_front()
				stack.pop_front()
				stack.push_front( aux )
			elif( aRpn[i] == '%'):
				aux = int(stack[1]) % int(stack[0])
				stack.pop_front()
				stack.pop_front()
				stack.push_front( aux )
			elif( aRpn[i] == ' ' ):
				continue
	return int(stack[0])

# return a math expression string in Reverse Polish Notation separeted by ' '
func sRpn( string ):
	var sOutput = ''
	var stack = [ ]
	var sPrecedence = {  '+' : 1, '-' : 1, '*' : 2, '/' : 2, '%' : 2, '(' : 3 }
	var nearLeft = true
	# read a token.
	for s in string:
		# if the token is a number, then add it to the output queue.
		if ( s.is_valid_integer() ):
			sOutput += s 
			if( ! stack.empty() and stack[0] == '(' ):
				nearLeft = false
		# if the token is an operator then:
		elif ( s == '+' or s == '-' or s == '*' or s == '/' or s == '%' or s == '(' or s == ')' ):
			# put the signal negative number '-' in output queue after '(' or discard the '+'
			if( ! stack.empty() ):
				if( s == '-' and sOutput != '' and stack[0] == '(' and nearLeft):
					sOutput += ' '
					sOutput += s
					nearLeft = false
					continue
				if( s== '+' and sOutput != '' and stack[0] == '(' and nearLeft ):
					nearLeft = false
					continue
			# if sOutput is '' and token is '+' or '-' then add it to the output
			# this consider a valid integer negative or positive number, ie +5 or -3, it is ok!
			if ( sOutput == '' and (s == '+' or s == '-') ):
				if ( s == '-' ):
					sOutput += s
				continue
			# if token is an operator then put ' ' in the queue to separate the terms
			if ( s == '+' or s == '-' or s == '*' or s == '/' or s == '%' ):
				sOutput += ' '
			# if the token is a left parenthesis or stack is empty, push it onto the stack.
#			if( s == '(' ):
#				sOutput += '_'
			if (  stack.empty() or s == '(' ):
				nearLeft = true
				stack.push_front(s)
				continue
			# if the token is an operator different then '(' and stack is not empty
			else:
				# if token is ')' util the token at top of the stack is a '(' 
				# pop operators off the stack onto output queue except '(' that only pop the stack
				if ( s == ')' ):
					while ( stack[0] != '(' ):
						sOutput += ' '
						sOutput += str(stack[0])
						stack.pop_front()
						continue
					stack.pop_front()
					continue
				# If token is an operator
				else:
					# while there is an operator at the top of the stack and either...
					while ( ! stack.empty() ):
						# if 's' is left-associative and its precedence is less than or equal to stack[0]
						if (  sPrecedence[s] <= sPrecedence[stack[0]] and stack[0] != '('):
							# pop it off the stack onto the output queue
							sOutput += str(stack[0])
							sOutput += ' '
							stack.pop_front()
							continue
						else:
							break
					# push 's' to stack
					stack.push_front(s)
	# After process still remain operators on stack, add they to output queue
	if ( ! stack.empty() ) :
		while ( ! stack.empty() ):
			sOutput += ' '
			sOutput += str(stack[0])
			stack.pop_front()
	return sOutput











# ---------------------------------- GARBAGE -------------------------------------
	
#func solveRoman( string ):
#	var n = 0
#	for s in string:
#		if( s == 'I' ):
#			n += 1
#		elif( s == 'V' ):
#			n += 5
#		elif( s == 'X' ):
#			n += 10
#		elif( s == 'L' ):
#			n += 50
#		elif( s == 'C' ):
#			n += 100
#		elif( s == 'D' ):
#			n += 500
#		elif( s == 'M' ):
#			n += 1000
#	if( 'IV'.is_subsequence_of(string) ):
#		n -= 2
#	if( 'IX'.is_subsequence_of(string) ):
#		n -= 2
#	if( 'XL'.is_subsequence_of(string) ):
#		n -= 20
#	if( 'XC'.is_subsequence_of(string) ):
#		n -= 20
#	if( 'CD'.is_subsequence_of(string) ):
#		n -= 200
#	if( 'CM'.is_subsequence_of(string) ):
#		n -= 200
#	return n














