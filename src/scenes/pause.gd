
extends Node2D


var can_press = false
var sound
var camera
var c
var root
signal handle_pause(is_paused)

func _ready():
	sound = get_node("SamplePlayer")
	c = get_node("/root/Controller")
	var _root=get_tree().get_root()
	root = _root.get_child(_root.get_child_count()-1)
	camera = get_tree().get_root().get_node("root").find_node("Camera")
	
	set_fixed_process(true)
	

func _fixed_process(delta):
	if (not Input.is_action_pressed("pause")):
		can_press = true
	elif (can_press and Input.is_action_pressed("pause")):
		doapause()
			
func doapause():
	print("lets go")
	can_press = false
	
	if (get_tree().is_paused()):
		sound.play("cancel")
		get_tree().set_pause(false)
#		camera.set("zoom",Vector2(1,1))
		get_node("AnimationPlayer").play("unpause")
		emit_signal("handle_pause",false)
		
	elif (root.map_names[c.current_map_name] != "title" != 0):
#		camera.set("zoom",Vector2(0.5,0.5))
		
		#get_tree().set_pause(true)
		get_node("Pause/Controls").set_text(c.dialog["Controls"])
		get_node("AnimationPlayer").play("pause")
		emit_signal("handle_pause",true)
		sound.play("accept")
func pause():
	get_tree().set_pause(true)