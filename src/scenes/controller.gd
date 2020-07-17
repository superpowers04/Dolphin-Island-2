extends Node

var root
# Lifeforce Management

var lf_active = true
var full_lifeforce = true
var lifeforce_timer
var death = false
var lf_time = 8
const LF_UP = 3
var progress
# Scene Management Variables
var map_layer
var current_map = null
var current_map_name = null
var checkpoint = 0
var player
# UI Variables
var ui # UI Node
var fader
var bosshp
var face_anim
var text_win
# Camera Variables
var camera
var cam_collision
var cam_target = null
var player_class = preload("res://scenes/player.gd")
var is_shaking
var shake_state = "none"
const CAM_OFFSET = -16
const CAM_HSTR = 3#4
const CAM_VSTR = 12#4
const CAM_CUTS = 12
# Sound variables
var snd_manager
# Input variables
var cutscene = false
var press_full = false
var cutsceneis

# Input
var walk_leftk
var walk_rightk
var walk_upk
var walk_downk
var jumpkeyk
var attackkeyk
var dash_butk
#Default keys
var walk_left_key = "a"
var walk_right_key = "d"
var walk_up_key = "w"
var walk_down_key = "s"
var jump_key = "space"
var attack_key = "control"
var dash_key = "shift"
#Key names
var walk_up_key_name = "up"
var walk_down_key_name = "down"
var walk_right_key_name = "right"
var walk_left_key_name = "left"
var jump_key_name = "A"
var dash_key_name = "B"
var attack_key_name = "X"


#Text
var menutext = ""
var titlescreentext = {1 : "Press Z to start"}
var dialog = {}
var configfileloc= "user://dolphin_island_config.txt" 
var langfileloc= "user://dolphin_island_lang.txt" 
var controllerconnected = false
var controllerwasconnected = controllerconnected



func _ready():
#	OS.set_iterations_per_second(60)
#	OS.set_target_fps(60)
	
	
	OS.set_window_maximized(true)
	randomize()
	var _root=get_tree().get_root()
	root = _root.get_child(_root.get_child_count()-1)
	lifeforce_timer = root.get_node("LifeforceTimer")
	progress = get_node("/root/Progress")
	ui = root.get_node("UILayer/UI")
	print(["ui ",ui])
	bosshp = ui.get_node("BossHP")
	fader = root.get_node("UILayer/Fade")
	face_anim = ui.get_node("FaceAnim")
	text_win = ui.get_node("TextWindow")
	map_layer = root.get_node("Map")
	camera = root.get_node("Map/Camera")
	camera.make_current()
	snd_manager = get_node("/root/SoundManager")
	
	# Config file
	
	var configFile= ConfigFile.new() 
	configFile.load(configfileloc) 
	
	if Input.is_joy_known(0):
		walk_up_key_name = "up"
		walk_down_key_name = "down"
		walk_right_key_name = "right"
		walk_left_key_name = "left"
		jump_key_name = "A"
		dash_key_name = "B"
		attack_key_name = "X"
		
		
		titlescreentext = {1 : str("Press ", jump_key_name,", or ",attack_key_name," to start")}
		dialog = { "TutorialIntro" : ["[Sora]: You're inside. \nTry to get used to this digital form.",
				"[Aisha]: Sweet outfit. \nI even got a badass sword!", 
				"[Sora]: Haha. Don't get so excited. \nGo take a look around."], 
				"DashIntro" : ["[Aisha]: Hey, Uhh How am\n I supposed to get across this gap?", "[Sora]: Dash across.\n You can dash in any direction aswell","[Aisha]: Oh, Thanks!"],
				"1Arenabeat" : ["You got a Lifeforce Crystal!", "Your shield will regenerate faster now."], "1BossDead" : ["You got the Air Slash!", str("Press ", walk_up_key_name, "+", attack_key_name ," to execute a stronger attack.")] ,
				"1Classmate" : ["[Aisha]: Megan! It's you!", "[Megan]: Aisha! Thank God. \nI've been so alone.", "[Aisha]: Don't worry, we'll get you out \nof here. Have you seen the others?", "[Megan]: No, I haven't left this \nplace since I arrived.",
				"[Aisha]: Alright. Sora? \nIf you would, please.", "[Sora]: Right on it!", "[Aisha]: See you outside."], "Controls":
				str("Controls:\n",walk_up_key_name," to use charged attack(Unlockable)\nor to aim up for dash\n",walk_left_key_name," and ", walk_right_key_name," to move left and right\n",walk_down_key_name," to crouch/slide\n",jump_key_name," to jump\n",attack_key_name," To attack\n",dash_key_name," to dash","\nL to reset if stuck")
				,"controller_disconnected":[str("Controller was disconnected!, Press ",attack_key_name, " to continue")],"controller_connected":[str("Controller connected, Press A or the equivelent to continue")]}

	
	
	if (configFile.has_section_key("config", "version")): 
		print("Config file exists!")
		walk_up_key = configFile.get_value("keys", "key_up")
		walk_down_key = configFile.get_value("keys", "key_down")
		walk_right_key = configFile.get_value("keys", "key_right")
		walk_left_key = configFile.get_value("keys", "key_left")
		jump_key = configFile.get_value("keys", "key_jump")
		attack_key = configFile.get_value("keys", "key_attack")
		dash_key = configFile.get_value("keys", "key_dash")

		OS.set_target_fps(configFile.get_value("config", "FPS"))
	else:
		print("Config file doesn't exist, Creating!")
		configFile.set_value("config","OS",OS.get_name())
		configFile.set_value("keys","key_up",walk_up_key) 
		configFile.set_value("keys","key_down",walk_down_key)
		configFile.set_value("keys","key_right",walk_right_key)
		configFile.set_value("keys","key_left",walk_left_key)
		configFile.set_value("keys","key_jump",jump_key)
		configFile.set_value("keys","key_attack",attack_key)
		configFile.set_value("keys","key_dash",dash_key)
		configFile.set_value("config","version","0.1")
		configFile.set_value("config","FPS",60)
		configFile.save(configfileloc)

# Handle key names
	walk_up_key_name = walk_up_key
	walk_down_key_name = walk_down_key
	walk_right_key_name = walk_right_key
	walk_left_key_name = walk_left_key
	jump_key_name = jump_key
	dash_key_name = dash_key
	attack_key_name = attack_key


	#Handle dynamic text
	if !Input.is_joy_known(0):
		controllerconnected = true
		controllerwasconnected = true
		titlescreentext = {1 : str("Press ", jump_key_name,", or ",attack_key_name," to start")}
		dialog = { "TutorialIntro" : ["[Sora]: You're inside. \nTry to get used to this digital form.",
				"[Aisha]: Sweet outfit. \nI even got a badass sword!", 
				"[Sora]: Haha. Don't get so excited. \nGo take a look around."], 
				"DashIntro" : ["[Aisha]: Hey, Uhh How am\n I supposed to get across this gap?", "[Sora]: Dash across.\n You can dash in any direction aswell","[Aisha]: Oh, Thanks!"],
				"1Arenabeat" : ["You got a Lifeforce Crystal!", "Your shield will regenerate faster now."], "1BossDead" : ["You got the Air Slash!", str("Press ", walk_up_key_name, "+", attack_key_name ," to execute a stronger attack.")] ,
				"1Classmate" : ["[Aisha]: Megan! It's you!", "[Megan]: Aisha! Thank God. \nI've been so alone.", "[Aisha]: Don't worry, we'll get you out \nof here. Have you seen the others?", "[Megan]: No, I haven't left this \nplace since I arrived.",
				"[Aisha]: Alright. Sora? \nIf you would, please.", "[Sora]: Right on it!", "[Aisha]: See you outside."], "Controls":
				str("Controls:\n",walk_up_key_name," to use charged attack(Unlockable)\nor to aim up for dash\n",walk_left_key_name," and ", walk_right_key_name," to move left and right\n",walk_down_key_name," to crouch/slide\n",jump_key_name," to jump\n",attack_key_name," To attack\n",dash_key_name," to dash","\nL to reset if stuck")
				,"controller_disconnected":[str("Controller was disconnected!, Press ",attack_key_name, " to continue")],"controller_connected":[str("Controller connected, Press A or the equivelent to continue")]}

	#Handle keycode conversions








	walk_up_key = OS.find_scancode_from_string(walk_up_key)
	walk_down_key = OS.find_scancode_from_string(walk_down_key)
	walk_right_key = OS.find_scancode_from_string(walk_right_key)
	walk_left_key = OS.find_scancode_from_string(walk_left_key)
	jump_key = OS.find_scancode_from_string(jump_key)
	attack_key = OS.find_scancode_from_string(attack_key)
	dash_key = OS.find_scancode_from_string(dash_key)

	
	set_fixed_process(true)

func _fixed_process(delta):
#	print(current_map.get_child_count())
#	print(checkpoint)
	#Input
	walk_leftk = Input.is_key_pressed(walk_left_key) || Input.is_action_pressed("ui_left")
	walk_rightk = Input.is_key_pressed(walk_right_key) || Input.is_action_pressed("ui_right")
	walk_upk = Input.is_key_pressed(walk_up_key) || Input.is_action_pressed("ui_up")
	walk_downk = Input.is_key_pressed(walk_down_key) || Input.is_action_pressed("ui_down")
	jumpkeyk = Input.is_key_pressed(jump_key) || Input.is_action_pressed("jump")
	attackkeyk = Input.is_key_pressed(attack_key) || Input.is_action_pressed("attack")
	dash_butk = Input.is_key_pressed(dash_key) || Input.is_action_pressed("attack2")
	controllerconnected = Input.is_joy_known(0)
#	if controllerconnected != controllerwasconnected:
#		if Input.is_joy_known(0):
#			show_text(dialog["controller_connected"])
#		else:
#			show_text(dialog["controller_disconnected"])
#		controllerwasconnected = controllerconnected



	if (cam_target != null):
		scroll_camera()
	else:
		camera.set_pos(Vector2(160,90))

	if (is_shaking):
		cam_shake()
	# Manage Input
	if (Input.is_action_pressed("exit")):
		get_tree().quit()
	if (!Input.is_action_pressed("fullscreen")):
		press_full = false
	elif (not press_full and Input.is_action_pressed("fullscreen")):
		press_full = true
		if (OS.is_window_fullscreen()):
			OS.set_window_fullscreen(false)
		else:
			OS.set_window_fullscreen(true)

	# Manage Lifeforce
	var orb = ui.get_node("Orb")
	if (lf_active):

		
		
		var lifeforce_bar = ui.get_node("BarFill")
		if (lifeforce_timer.get_time_left() > 0):
			var raw_progress = lifeforce_timer.get_wait_time()-lifeforce_timer.get_time_left()
			var max_progress = lifeforce_timer.get_wait_time()
			var progress = raw_progress*100/max_progress
			lifeforce_bar.set_value(progress)
			orb.hide()
		elif (full_lifeforce and orb.is_hidden()):
			lifeforce_bar.set_value(100)
			orb.show()
	else:
		var lifeforce_bar = ui.get_node("BarFill")
		lifeforce_bar.set_value(0)
		orb.hide()
		lifeforce_timer.stop()
		full_lifeforce = false
		

	

func life_up():
	var time = lf_time - LF_UP * progress.checks["1ShieldUpgrade"]
	time -= LF_UP * LF_UP * progress.checks["2ShieldUpgrade"] + LF_UP * progress.checks["3ShieldUpgrade"]
	if (not full_lifeforce):
		snd_manager.play_sfx("ding")
		ui.get_node("Effects").play("FullHP")
	full_lifeforce = true
	lifeforce_timer.stop()
	lifeforce_timer.set_wait_time(time)

func life_down():
	if (not death):
		change_face("Hurt")
		if (not full_lifeforce):
			death = true
			get_player().death()
			lifeforce_timer.stop()
			root.get_node("DeathTimer").start()
		else:
			snd_manager.play_sfx("hurt",true)
			lifeforce_timer.start()
			full_lifeforce = false

func get_player():
	var player_array = get_tree().get_nodes_in_group("Player")
	return player_array[player_array.size()-1]

func scroll_camera():
# Camera distance to player
#	print([cam_target, cam_target.get_name()])
	var pos = camera.get_global_pos()
	var opos = cam_target.get_global_pos()
	opos.y += CAM_OFFSET
	var dist = opos - pos
	dist = Vector2(round(dist.x),round(dist.y))
	var move = Vector2(dist.x/(CAM_HSTR + CAM_CUTS*(cam_target != player)), dist.y/CAM_VSTR)
#	print(dist)
	if (abs(move.x) < 1):
		move.x = sign(move.x)
	if (abs(move.y) < 1):
		move.y = sign(move.y)
		
#	# Horizontal scrolling
	if (dist.x != 0):
		pos.x += move.x
			
	# Vertical scrolling
	if (dist.y != 0):
		pos.y += move.y
#	
	pos.y = round(pos.y)
	pos.x = round(pos.x)
	# Resolve movement
	camera.set_pos(pos)

func cam_shake():
	if (shake_state == "none"):
		camera.set_offset(Vector2(-2,-2))
		shake_state = "tl"
	elif (shake_state == "tl"):
		camera.set_offset(Vector2(0,0))
		shake_state = "zero"
	elif (shake_state == "zero"):
		camera.set_offset(Vector2(2,2))
		shake_state = "br"
	elif (shake_state == "br"):
		camera.set_offset(Vector2(0,0))
		is_shaking = false
		shake_state = "none"

func show_text(text):
	text_win.show_text(text)

func change_face(text):
	face_anim.play(text)
	face_anim.queue("Neutral")
	
func begin_cutscene():
	#var playyy = get_player()
	cutscene = true
	
#	player.falling = false
#	player.jumping = false
#	player.attacking = false
#	player.top_sprite.play("Idle")
#	player.bot_sprite.play("Idle")

func end_cutscene():
	cutscene = false
	cutsceneis = ""
#	player.top_sprite.play("donetransmission")

func show_bosshp(value):
	bosshp.show()
	bosshp.top = value
	bosshp.current = 0

func hide_bosshp():
	bosshp.hide()
	bosshp.top = 1
	bosshp.current = 0
	bosshp.bar.set_value(0)