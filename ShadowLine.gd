extends Node

class_name ShadowLine

var shadows = []

func isInShadow(projection: Shadow):
	for shadow in shadows:
		if shadow.contains(projection):
			return true
	return false

func isFullShadow():
	return shadows.size() == 1 && shadows[0].start == 0 && shadows[0].end == 1
	
func add (shadow: Shadow):
	var index = 0
	# Figure out where to slot the new shadow in the list.
	for i in range(shadows.size()):
		if shadows[i].start >= shadow.start: 
			break
		index +=1
			
	# The new shadow is going here. See if it overlaps the
	# previous or next.
	var overlappingPrevious
	if index > 0 && shadows[index - 1].end > shadow.start:
		overlappingPrevious = shadows[index - 1]
	
	var overlappingNext
	if index < shadows.size() && shadows[index].start < shadow.end:
		overlappingNext = shadows[index]

	 # Insert and unify with overlapping shadows.
	if overlappingNext != null:
		if overlappingPrevious != null: 
			# Overlaps both, so unify one and delete the other.
			overlappingPrevious.end = overlappingNext.end;
			shadows.remove(index);
		else:
			# Overlaps the next one, so unify it with that.
			overlappingNext.start = shadow.start;
	else:
		if overlappingPrevious != null:
			# Overlaps the previous one, so unify it with that.
			overlappingPrevious.end = shadow.end;
		else:
			# Does not overlap anything, so insert.
			shadows.insert(index, shadow);
