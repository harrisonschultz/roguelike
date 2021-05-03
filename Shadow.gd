extends Node


class_name Shadow

var start
var end

func _init(s, e):
	start = s
	end = e

func contains(other: Shadow):
	if start <= other.start && end >= other.end:
		return true
	else:
		return false



