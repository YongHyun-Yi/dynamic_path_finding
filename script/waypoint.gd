extends Area2D

var clicked = false
var clicked_start_point : Vector2
var drag = false
var drag_pos : Vector2
var index : int
onready var unit = get_node("../..")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if clicked == true and drag == false:
		if clicked_start_point != get_global_mouse_position():
			drag = true
		# Change drag variable to true if the click start point and the current mouse position are different with the unit clicked
	
	if drag == true:
		# Enable drag mode
		# I will use two waypoints(Previous and Next Point) as if I had inserted a waypoint in the middle.
		# Use one waypoint(Previous Point) if you move the end waypoint.
		
		if drag_pos != get_global_mouse_position():
			# Run only when drag position is updated
			
			drag_pos = unit.nav.get_closest_point(get_global_mouse_position())
			# Obtain a valid close position in the navigation2d polygon from the current drag position
			
			global_position = drag_pos
			# update position of dragged waypoint
			
			#---------
			var waypoint1
			var waypoint2
			
			var copy_left_path_array
			
			var a
			var b
			
			var index_change_size
			
			# The variables and methods used are almost the same as inserting a waypoint in the middle in the
			
			waypoint1 = get_parent().get_child(get_index()-1)
			if get_parent().get_child_count()-1 > get_index(): 
				waypoint2 = get_parent().get_child(get_index()+1)
				# If the currently selected waypoint is not the last point, Obtain the next waypoint
			
			var path_array = Array(unit.path)
			if waypoint2:
				copy_left_path_array = path_array.slice(waypoint2.index, unit.path.size()-1)
				copy_left_path_array.remove(0)
				# The explanation is the same as before. The only difference is whether or not we've got a waypoint2.
			
			a = unit.nav.get_simple_path(unit.path[waypoint1.index], global_position)
			a.remove(0)
			
			if waypoint2:
				b = unit.nav.get_simple_path(global_position, unit.path[waypoint2.index])
				b.remove(0)
			
			path_array.resize(waypoint1.index+1)
			path_array = PoolVector2Array(path_array)
			
			path_array.append_array(a)
			var insert_index = path_array.size()-1
			
			if waypoint2:
				path_array.append_array(b)
				index_change_size = (path_array.size()-1) - waypoint2.index
			
				path_array.append_array(copy_left_path_array)
				
				for i in range(get_index()+1, get_parent().get_child_count()):
					get_parent().get_child(i).index += index_change_size
			
			unit.path = path_array
			index = insert_index
			#---------
			
			unit.line2d.points = unit.path
	pass

func _input(event):
	if event.is_action_released("left_click"):
		if clicked == true:
			clicked = false
			drag = false
			clicked_start_point = Vector2()
		# When release with the mouse, Clicked and drag variables change to false
		# Initialize click start point

func _on_waypoint_input_event(viewport, event, shape_idx):
	
	if event is InputEventMouseButton:
		if event.is_action_pressed("left_click"):
			if clicked == false:
				clicked = true
				clicked_start_point = event.position
			# When the waypoint is clicked, clicked variable change to true
			# Assign mouse event location to click start point

func command_excute():
	print("excute command!")
	unit.move_path()
	queue_free()
