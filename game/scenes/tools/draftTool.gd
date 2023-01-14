extends Node


func _ready():
	var string = '12345()'
	var s = string.substr(0,string.find('('))
	string.erase(string.find('('),2)
	print(string)
	print(s)


