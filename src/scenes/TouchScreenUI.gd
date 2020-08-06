extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	



func _handle_pause( is_paused ):
	if is_paused:
		get_node("Buttons").set("visibility/visible",false)
	else:
		get_node("Buttons").set("visibility/visible",true)
