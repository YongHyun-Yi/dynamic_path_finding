extends Node2D

onready var line2d = $Line2D
onready var nav = $Navigation2D
onready var character = $character
onready var waypoint = preload("res://scene/waypoint.tscn")

var path : PoolVector2Array
var move = false
var speed = 200.0



func _ready():
	path_initiate()

# ------------------------

func path_initiate():
	path.resize(0)
	path.append(character.global_position)
	
	var order = waypoint.instance()
	order.global_position = character.global_position
	order.index = 0
	order.input_pickable = false
	$orders.add_child(order)
	
	update_path_draw()

# ------------------------

func update_path_draw():
	var path_line : PoolVector2Array
	path_line.append(character.global_position)
	
	for i in $orders.get_children():
		if not i.path:
			continue
		
		var a = i.path
		a.remove(0)
		path_line.append_array(a)
	
	line2d.points = path_line

# ------------------------

func _process(delta):
	if move == true:
		line2d.points[0] = character.global_position

# ------------------------

func _input(event):
	if Input.is_action_just_pressed("right_click"):
		if character.clicked == true and move == false:
			
			var insert_index = null
			var move_point = nav.get_closest_point(event.position)
			
			if $orders.get_child_count() > 1:
				for i in $orders.get_children():
					if not i.path:
						continue
					
					insert_index = insert_point_check(i, event.position, move_point)
					if insert_index:
						break
			
			if insert_index == null:
				var waypoint1 = $orders.get_child($orders.get_child_count()-1)
				waypoint_add(waypoint1, move_point)
			
			update_path_draw()
	
	if Input.is_action_just_pressed("ui_select"):
		if move == false:
			move = true
			$orders.get_child(0).command_excute()

# ------------------------

func insert_point_check(waypoint1, event_position, move_point):
	var squared_width = line2d.width * line2d.width
	for i in waypoint1.path.size()-1:

		var cloest_point = Geometry.get_closest_point_to_segment_2d(move_point, waypoint1.path[i], waypoint1.path[i+1])
		if cloest_point.distance_squared_to(event_position) > squared_width:
			continue
		
		var insert_index = waypoint_insert(waypoint1, cloest_point)
		
		return insert_index

# ------------------------

func waypoint_insert(waypoint1, cloest_point):
	
	var insert_index = waypoint1.get_index()+1
	var waypoint2 = $orders.get_child(insert_index)
	
	waypoint1.path = nav.get_simple_path(waypoint1.global_position, cloest_point)
	
	var order = waypoint.instance()
	order.global_position = cloest_point
	order.index = insert_index
	order.path = nav.get_simple_path(order.global_position, waypoint2.global_position)
	$orders.add_child(order)
	$orders.move_child(order, waypoint2.get_index())
	
	for x in $orders.get_children():
		x.index = x.get_index()
	
	return insert_index

# ------------------------

func waypoint_add(waypoint1, move_point):
	waypoint1.path = nav.get_simple_path(waypoint1.global_position, move_point)
	var order = waypoint.instance()
	order.global_position = move_point
	order.index = waypoint1.get_index()+1
	$orders.add_child(order)

# ------------------------

func move_path():
	var tween = $Tween
	tween.interpolate_property(character, "position", path[0], path[1], path[0].distance_to(path[1])/speed,  Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()


func move_tween_finish():
	
	path.remove(0)
	
	if path.size() > 1:
		move_path()
	else:
		$orders.get_child(0).command_excute()
	
	line2d.remove_point(0)
