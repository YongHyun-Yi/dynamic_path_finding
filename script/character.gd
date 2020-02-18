extends Area2D


var clicked = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_StaticBody2D_input_event(viewport, event, shape_idx):
	
	if event is InputEventMouseButton:
		if event.is_action_pressed("left_click"):
			if clicked == false:
				clicked = true
				modulate = "3fff00"
			print("unit selected!")
	
	pass # Replace with function body.
