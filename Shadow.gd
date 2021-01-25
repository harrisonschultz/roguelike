extends Node


class_name Shadow

var start
var end

func _init(s, e):
	start = s
	end = e

func contains(other: Shadow):
	#print(str(start) + " <= " + str(other.start) + " && " + str(end)  + " >= " + str(other.end))
	#var res = start <= other.start && end >= other.end
	#print(res)
	if start <= other.start && end >= other.end:
		return true
	else:
		return false



