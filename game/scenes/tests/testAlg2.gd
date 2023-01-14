
extends Control

var Shl = preload('shLabel.gd')     ############################
var iHeight = 7
var iWidth = 7
var iStage = 1
onready var timer = get_node("Timer")
var bHit = false


var dCellsMap = {
Vector2(0,0) : ' ',Vector2(1,0) : '3',Vector2(2,0) : '-',Vector2(3,0) : '2', Vector2(4,0) : '$',Vector2(5,0) : '=', Vector2(6,0) : '1', 
Vector2(0,1) : '$',Vector2(1,1) : '$',Vector2(2,1) : '8',Vector2(3,1) : '=', Vector2(4,1) : '8',Vector2(5,1) : '*', Vector2(6,1) : '1',
Vector2(0,2) : '$',Vector2(1,2) : '-',Vector2(2,2) : '6',Vector2(3,2) : '=', Vector2(4,2) : '+',Vector2(5,2) : '-', Vector2(6,2) : '5',
Vector2(0,3) : '5',Vector2(1,3) : '+',Vector2(2,3) : '3',Vector2(3,3) : '-', Vector2(4,3) : '2',Vector2(5,3) : '$', Vector2(6,3) : '8',
Vector2(0,4) : '$',Vector2(1,4) : '6',Vector2(2,4) : '-',Vector2(3,4) : '2', Vector2(4,4) : '=',Vector2(5,4) : '4', Vector2(6,4) : '+',
Vector2(0,5) : '$',Vector2(1,5) : '$',Vector2(2,5) : '=',Vector2(3,5) : '3', Vector2(4,5) : '3',Vector2(5,5) : '$', Vector2(6,5) : '=',
Vector2(0,6) : '8',Vector2(1,6) : '=',Vector2(2,6) : '9',Vector2(3,6) : '+', Vector2(4,6) : '$',Vector2(5,6) : '$', Vector2(6,6) : '4',
}
var dResult = {}
var string1 = "-12+58-25=78+90=152 45"

var str_1 = '-1*2*(13+4)' # -34
var str_2 = '22*3+4*(5-6)' # 62
var str_3 = '-1250*3-(-4*(-5-2)-1258)+356' # -2.108

func _ready():
#	test( str_3 )
#	print ( sRpn(str1) )
#	print ( isValidString(str1) )
#	print ( '0'.is_valid_integer())
	printDict(dCellsMap,iHeight,iWidth)
	var shl = Shl.new()
	shl.set_pos(Vector2(0,0))	 ############################
	shl.set_hidden(false)		 ############################
	shl.set_text('test')		 ############################
	hitDict(checkHit())
	
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
	print ( 'dResul: ', dResult )
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
	timer.disconnect( "timeout",self,"pieceMoveDown" )	
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
	timer.connect( "timeout",self,"pieceMoveDown", [true] )

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
	var sOk = '0123456789 ()+-*_'	
	var amountOfNumber = 0
	var iCountLeft = 0
	var iCountRight = 0
	if ( string.empty() ):
		return false
	if ( string.begins_with('*') or string.begins_with(')') ):
		return false
	if ( string.ends_with('*') or string.ends_with('(') ):
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
			elif( aRpn[i] == ' ' ):
				continue
	return int(stack[0])

# return a math expression string in Reverse Polish Notation separeted by ' '
func sRpn( string ):
	var sOutput = ''
	var stack = [ ]
	var sPrecedence = {  '+' : 1, '-' : 1, '*' : 2, '(' : 3 }
	var nearLeft = true
	# read a token.
	for s in string:
		# if the token is a number, then add it to the output queue.
		if ( s.is_valid_integer() ):
			sOutput += s 
			if( ! stack.empty() and stack[0] == '(' ):
				nearLeft = false
		# if the token is an operator then:
		elif ( s == '+' or s == '-' or s == '*' or s == '(' or s == ')' ):
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
			if ( s == '+' or s == '-' or s == '*'):
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

