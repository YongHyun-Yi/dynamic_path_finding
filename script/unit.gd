extends Node2D

onready var line2d = $Line2D
onready var nav = $Navigation2D
onready var character = $character
onready var waypoint = preload("res://scene/waypoint.tscn")

var path : PoolVector2Array
var move = false
var speed = 200.0


# I recommend placing unit node in map (0, 0).
# I want to make it match with global coordinates.
# If you want to move the unit, move the character node.

func _ready():
	path_initiate()

func path_initiate():
	path.resize(0)
	path.append(character.global_position) # add current position to 'path' variable
	
	var order = waypoint.instance() # add current way point to 'orders' node
	order.global_position = character.global_position
	order.index = 0
	order.input_pickable = false # The waypoint of the current location cannot be moved.
	$orders.add_child(order)
	
	line2d.points = path # update drawn path by line2d

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if move == true:
		line2d.points[0] = character.global_position
		# if unit move, updating current position on line2d
	pass

func _input(event):
	if Input.is_action_just_pressed("right_click"):
		if character.clicked == true and move == false:
			# if character was selected and not moving yet
			
			var insert_index = null
			
			if path.size() > 1: 
				# if you had multiple waypoint path size maybe larger than 1 (current position).
				#Than You can insert a new waypoint between the Waypoints.
				
				for i in range(path.size()-1):
					#Two points will be checked in path. The starting and ending values. Then I took 1 out of range.
					
					var squared_width = line2d.width * line2d.width
					var cloest_point = Geometry.get_closest_point_to_segment_2d(event.position, path[i], path[i+1])
					# Locate the closest point where the mouse click event occurred between the start value and the next (end value).
					
					if cloest_point.distance_squared_to(event.position) <= squared_width:
						# If the distance between the close point and the position where the mouse click event occurred is less than the size of line2d,
						# = If you clicked a line drawn in line2d,
					
						for l in $orders.get_children():
							# The event is based on the waypoint, not the paths within the 'path' variable.
							# Obtain the way points before and after of the click point
							# Each waypoint node has a variable that stores index values within the 'path' variable.
							
							if i < l.index:
								# For loop starts and rises from zero. 
								# The waypoint that grows in size compared to the index value close to the clicked point is the waypoint after the click point.
								
								var waypoint1 = $orders.get_child(l.get_index()-1)
								var waypoint2 = l
								#In the waypoint1 variable, stores the previous waypoint of 'l' and than store 'l' in the waypoint2 variable.
								
								var path_array = Array(path)
								# It's like a surgery where you cut and take out an existing part and put in a new part.
								# To use the method of array, convert the 'path' variable to array and save it anew.
								# We will combine the two arrays by specifying new paths from waypoint1 to click point and new paths from click point to waypoint2.
								# get simple path includes start and end points Deletes elements that are likely to overlap.
								
								var copy_left_path_array = path_array.slice(waypoint2.index, path.size()-1) # First, copy from waypoint2 to the last path.
								copy_left_path_array.remove(0) # The coordinates of the waypoint 2 will overlap, so I will delete
								
								var a = nav.get_simple_path(path[waypoint1.index], event.position) # Obtain path from waypoint1 to click event point and save to variable
								a.remove(0) # The coordinates of waypoint 1 will be duplicated, so I will delete them.
								
								var b = nav.get_simple_path(event.position, path[waypoint2.index]) # Click to locate the path from the event point to waypoint2 and save it to a variable
								b.remove(0) # The coordinates of the click point will overlap, so I will delete them.
								
								path_array.resize(waypoint1.index+1)
								# We're going to start the surgery on the path_array variable that we previously copied and stored.
								# The 'size' is 1 larger than index, so adjust the size of array by +1 on the index of the waypoint1 that will be the starting point.
								
								path_array = PoolVector2Array(path_array) # Convert back to poolvector2array to use append_array method
								
								path_array.append_array(a) # Adds a redefined path from waypoin1.
								insert_index = path_array.size()-1
								# Since the last one is the coordinates of the click event, we will use this as index of the waypoint with size-1 of the array. Save to variable
								
								path_array.append_array(b) # Adds a redefined path from waypoin.
								var index_change_size = (path_array.size()-1) - l.index
								# The last coordinate is index of the next waypoint inserted waypoint.
								# If you subtract this index value from the index value before redefined path, you can see the amount of change in index.
								# Save to variable
								
								path_array.append_array(copy_left_path_array) # Re-seal path after waypoint2
								
								path = path_array # Overrides temporary path variables to original path variables
								
								var order = waypoint.instance() # Create a waypoint scene on the inserted part.
								order.global_position = event.position
								order.index = insert_index
								$orders.add_child(order)
								$orders.move_child(order, waypoint2.get_index())
								# Add to 'orders' node This is to keep the waypoint in place,
								# but all the waypoints are commands because the code was originally
								# intended to create a system such as the frozen synapse.
								# Move the node to index value of waypoint2 because it will be arranged in ascending order according to index value.
								
								for i in range(order.get_index()+1, $orders.get_child_count()):
									$orders.get_child(i).index += index_change_size
									# Add amount of change to index value from waypoint2 to last waypoint.
									pass
								
								break
						break
				
			if insert_index == null: # If you create a waypoint at a new point, not in the middle.
				var move_point = nav.get_closest_point(event.position)
				# Locate the point closest to where the mouse click event occurred in an area created by the navigation2d polygon.
				# navigation node's path finding only vail in the navigation2d polygon
				
				var a = nav.get_simple_path(path[path.size()-1], move_point)
				# Obtain a path from the last position of the 'path' variable to the move_point position
				
				a.remove(0)
				# The starting point of the new path overlaps with the last element of 'path' variable, so I'll delete it.
				
				path.append_array(a)
				# Add newly obtained path
				
				var order = waypoint.instance()
				order.global_position = move_point
				$orders.add_child(order)
				order.index = path.size()-1
				# Creates a waypoint scene and inserts the last index value of the array 'path' into the index variable of the waypoint.
			
			line2d.points = path
			# update line2d after inserting or adding a new path
	
	
	if Input.is_action_just_pressed("ui_select"):
		if move == false:
			move = true
			$orders.get_child(0).command_excute()
			# Press a specific key to enter the path execution mode.
			# First, follow the command of the first created waypoint.
			# In the waypoint scene, call the method that moves the character after the command is performed.
		pass

func move_path(): # Move along the path created path
	if path.size() > 1: # There must be at least two path points since the start and end points are required.
		var tween = $Tween
		tween.interpolate_property(character, "position", path[0], path[1], path[0].distance_to(path[1])/speed,  Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
		
		# I don't know why I calculated duration as 'path[0].distance_to(path[1])/speed'
		# I just reffering GDquest's tutorial - https://youtu.be/0fPOt0Jw52s
		# But I decided to simply use the tween node because there are unknown codes such as process = true.
		# I assembled the math equation that was shown in the tutorial video at random.
		# I'm sorry. I don't know what my formula means.
		# I gave up math a long time ago because my math ability was so bad by nature.
		
	pass


func move_tween_finish():
	
	path.remove(0)
	# Deletes the starting point of the path you just moved.
	
	for i in $orders.get_children():
		i.index -= 1
	# Update index value for all waypoints
	
	if $orders.get_child(0).index == 0:
		$orders.get_child(0).command_excute()
	else:
		move_path()
	# If the index of the current path matches the index of the waypoint, perform the command assigned to the waypoint.
	# All commands, as mentioned above, call the movement function after performance.
	# Otherwise, we'll just move.
	
	line2d.points = path
	# update drawn path by line2d
	
	if path.size() <= 1:
		path_initiate()
		move = false
	# If you don't have more than two point to use as a starting point and an end point,
	# End the move mode and initialize the path
