extends Area2D

var clicked = false
var clicked_start_point : Vector2
var drag = false
var drag_pos : Vector2
var index : int
var path : PoolVector2Array
onready var unit = get_node("../..")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# ------------------------
	
	if clicked == true and drag == false:
		if clicked_start_point != get_global_mouse_position():
			drag = true
	
	# ------------------------
	
	if drag == true:
		
		if drag_pos != get_global_mouse_position():
			
			drag_pos = unit.nav.get_closest_point(get_global_mouse_position())
			
			global_position = drag_pos
			
			# ------------------------
			
			var waypoint1 = get_parent().get_child(get_index()-1)
			waypoint1.path = unit.nav.get_simple_path(waypoint1.global_position, global_position)
			
			if path:
				var waypoint2 = get_parent().get_child(get_index()+1)
				path = unit.nav.get_simple_path(global_position, waypoint2.global_position)
			
			# ------------------------
			
			unit.update_path_draw()
			
	# ------------------------

func _input(event):
	if event.is_action_released("left_click"):
		if clicked == true:
			clicked = false
			drag = false
			clicked_start_point = Vector2()

func _on_waypoint_input_event(viewport, event, shape_idx):
	
	if event is InputEventMouseButton:
		if event.is_action_pressed("left_click"):
			if clicked == false:
				clicked = true
				clicked_start_point = event.position

func command_excute():
	print("excute command!")
	if path:
		unit.path = path
		unit.move_path()
	else:
		unit.path_initiate()
		unit.move = false
	queue_free()
