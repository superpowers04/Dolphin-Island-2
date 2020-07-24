extends KinematicBody2D

# Class controlling the player

# Movement Constants
const GRAVITY = 650.0
const FLOOR_ANGLE = 40
const WALK_FORCE = 600
const WALK_MIN = 10
const WALK_MAX = 200
const STOP_FORCE = 1300
const STOP_COEFF = 0.65
const MAX_JUMP = 0.105#0.65
const JUMP_VEL = 220#280
const MAX_AIR = 0.1 # Due to physics, character is always in the air. This is a tolerance
const FALL_ANIM_HEIGHT = 0#270
var direction = 1
var forceduck = false
var dashy =0
var dashx =0

# Variables
# Movement
var velocity = Vector2()	
var jumping = false
var can_jump = true
var falling = false
export var attacking = false # player is attacking
var can_attack = true
var can_dash = true
var air_time = 100
var jump_time
var storedxspeed = 0
var isdashing
# Input
var walk_left
var walk_right
var walk_up
var walk_down
var jump
var attack
var dash_but
var waitingtodie = false
# Combat
var hurtful_class = preload("res://scenes/hurtful.gd")
var killer_class = preload("res://scenes/killer.gd")
var enemy_class = preload("res://scenes/enemy.gd")
export var vulnerable = true
var knockback = false
var sword_hit = preload("res://scenes/sword_hit.scn")
var strong_hit = preload("res://scenes/strong_slash.xscn")
var attack_spot
export var create_sword = false
var aspd
var strong_slash
# Spritework
var sees_left = false
var top_sprite
var bot_sprite
var effects
export var need_synchro = false
var dust = preload("res://scenes/dust.scn")
var landed = false
var stopped = false
# Death
var smoke_effects = preload("res://scenes/smoke_effects.scn")
var dead = false
# Sounds
var sfx
# Cutscenes
var controller
var cutscene = false

var Effects2
var topbodspr
var botbodspr
var cutsceneis = ""
var noidle = false





func _ready():
	jump_time = get_node("Jump")
	jump_time.set_wait_time(MAX_JUMP)
	controller = get_node("/root/Controller")
	aspd = get_node("/root/Progress").checks["AttackSpeedUpgrade"]
	strong_slash = get_node("/root/Progress").checks["StrongSlash"]
	sfx = get_node("SamplePlayer")
	controller.cam_target = self
	attack_spot = get_node("AttackSpot")
	effects = get_node("Effects")
	Effects2 = get_node("Effects2")
	top_sprite = get_node("TopAnim")
	bot_sprite = get_node("BotAnim")
	topbodspr = get_node("TopBody")
	botbodspr = get_node("LowerBody")
	set_fixed_process(true)
	vulnerable = true
	#bot_sprite.play_backwards("revive")

func _fixed_process(delta):
	cutscene = controller.cutscene
	cutsceneis = controller.cutsceneis

	if (bot_sprite.get_current_animation() != "Victory" and effects.get_current_animation() != "Invulnerable"):
		effects.play("UpNone")
	if(not cutscene):
		walk_left = controller.walk_leftk 
		walk_right = controller.walk_rightk
		walk_up = controller.walk_upk
		walk_down = controller.walk_downk
		jump = controller.jumpkeyk
		attack = controller.attackkeyk
		dash_but = controller.dash_butk
		noidle = false
	else:
		if top_sprite.get_current_animation() != "transmission" and bot_sprite.get_current_animation() == "Idle" and cutsceneis != "":
			if cutsceneis == "TutorialIntro" or cutsceneis == "DashIntro":
				noidle = true
				top_sprite.set_current_animation("transmission")
				print(cutsceneis)
				need_synchro = true
		walk_left = false
		walk_right = false
		walk_up = false
		walk_down = false
		jump = false
		attack = false
	if Input.is_action_pressed("Reset"):
		controller.life_down()
		controller.life_down()
		controller.life_down()
		controller.life_down()
	if (not dead):
		_movement(delta)
		if Input.is_action_pressed("ui_page_up") and controller.checkpoint != 4:
			controller.checkpoint = controller.checkpoint + 1
			controller.life_down()
			controller.life_down()
			controller.life_down()
			controller.life_down()
			print("Going to ", controller.checkpoint)
		if waitingtodie:
			death()


func _movement(delta):
	# gravity
	var force = Vector2(0,GRAVITY)
	
	# stop by default, inertia
	var stop = true
#	print("V1:" + str(velocity.x) + " F:" + str(force.x))
	# Sideways movement
	#print(bot_sprite.get_current_animation() + " " + top_sprite.get_current_animation())

	if (can_dash and dash_but and (falling or jumping)):
		velocity.x = 0
		velocity.y = 0
		top_sprite.set_current_animation("None")
		bot_sprite.set_current_animation("Dash")
		if walk_down and (walk_left or walk_right):
			dashx = 250 * direction
			dashy = 200
			botbodspr.set_frame(88)
		elif walk_up and (walk_left or walk_right):
			dashx = 250 * direction
			dashy = -200
			botbodspr.set_frame(89)
		elif walk_up:
			dashx = 1 * direction
			dashy = -300
			botbodspr.set_frame(92)
		elif walk_down:
			dashx = 1 * direction
			dashy = 300
			botbodspr.set_frame(91)
		else:
			dashx = 400 * direction
			dashy = -1
			botbodspr.set_frame(90)
		velocity.x = dashx
		velocity.y = dashy
		isdashing = true
		
		Effects2.play("Dash")
		can_dash = false
		vulnerable = false	
	elif (walk_down and !falling and !jumping or forceduck):
		if ((velocity.x >= 1 or velocity.x<=-1) and bot_sprite.get_current_animation() != "Slide" ):
			velocity.x = storedxspeed * 0.5 * direction
			storedxspeed = 0
			STOP_FORCE = 200
			bot_sprite.set_current_animation("Slide")
			top_sprite.play("Slide")
			if (velocity.x>=-50 and velocity.x <= 50 ):
					velocity.x = 200 * direction
					
		elif (velocity.x>=-1 and velocity.x <= 1 and bot_sprite.get_current_animation() != "Duck" ):
			STOP_FORCE = 200
			velocity.x = storedxspeed * 0.5 * direction
			storedxspeed = 0
			bot_sprite.play("Duck")
			top_sprite.play("Jump")
	elif !waitingtodie:
		storedxspeed = 0
		STOP_FORCE = 1000
		if (walk_left and not walk_right):
			if (velocity.x<=WALK_MIN and velocity.x > -WALK_MAX):
				force.x-=WALK_FORCE
				stop = false
				stopped = false
				if (bot_sprite.get_current_animation() != "Run" and !jumping && !falling and !isdashing):
					bot_sprite.play("Run")
				if (top_sprite.get_current_animation() != "Run" and !is_attacking() and !jumping && !falling and !isdashing):
					top_sprite.play("Run")
			else:
				force.x = -WALK_FORCE * STOP_COEFF
		elif (walk_right and not walk_left):
			if (velocity.x>=-WALK_MIN and velocity.x < WALK_MAX):
				force.x+=WALK_FORCE
				stop = false
				stopped = false
				if (bot_sprite.get_current_animation() != "Run" and !jumping && !falling):
					bot_sprite.play("Run")
				if (top_sprite.get_current_animation() != "Run" and !is_attacking() and !jumping && !falling ):
					top_sprite.play("Run")
			else:
				force.x = WALK_FORCE * STOP_COEFF

			#

			
		
		



	# if the player got no movement, he'll slow down with inertia.
	if (stop):
		stop(delta)
		
#	print("V2:" + str(velocity.x) + " F:" + str(force.x))
	# calculate motion
	velocity += force * delta
	var motion = velocity * delta
#	motion = Vector2(round(motion.x),round(motion.y))
	motion = move(motion)
	
	
	# print("F:"+str(falling)+" J:"+str(jumping))
	# because the first move would stop if there's a collision, we recalculate the movement to slide along the colliding object.
	if (is_colliding()):
		#ran against something, is it the floor? get normal
		var n = get_collision_normal()
		
		if ( rad2deg(acos(n.dot( Vector2(0,-1)))) < FLOOR_ANGLE ):
			#if angle to the "up" vectors is < angle tolerance
			#char is on floor
			air_time=0
			falling = false
			can_dash = true

			if (not landed):
				create_dust("Land")
				sfx.play("step")
				landed = true
				
		
			#if angle to the "up" vectors is < angle tolerance
			#char is on floor
			
			

		# But we were moving and our motion was interrupted, 
		# so try to complete the motion by "sliding"
		# by the normal
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		
		#then move again
		move(motion)

	air_time+=delta
	
	if (jumping and velocity.y>=0):
		falling = true
		jumping=false
		
	if (velocity.y > 0 and air_time > MAX_AIR):
		falling = true
	
	if (velocity.y < 0 and bot_sprite.get_current_animation() != "Jump" and !isdashing):
		bot_sprite.play("Jump")
		if (!attacking):
			top_sprite.play("Jump")

	if (falling and bot_sprite.get_current_animation() != "Fall" and !isdashing):
		bot_sprite.play("Fall")
		if (!attacking):
			top_sprite.play("Fall")

	# Manage jumping
	if (!jump):
		can_jump = true
	elif (not jumping and can_jump and jump and not falling):
		can_jump = false
		sfx.play("jump")
		create_dust("Jump")
		if (not is_attacking()):
			top_sprite.play("Jump")
		bot_sprite.play("Jump")
		jumping=true
		jump_time.start()
		#if isdashing:
		#	velocity.y = -JUMP_VEL
		#	velocity.x = velocity.x * 1.4
		#else:
		velocity.y = -JUMP_VEL 
	
	# print("C:" + str(can_jump) + " J:" + str(jump))
#	print(jumping)
#	if (!jump):
#		print("LEAVE ME")
#		can_jump = true
#		if (jumping):
#			print("Leaves")
#			jumping = false
#	elif (can_jump and jump and not falling):
#		can_jump = false
#		sfx.play("jump")
#		create_dust("Jump")
#		if (not is_attacking()):
#			top_sprite.play("Jump")
#		bot_sprite.play("Jump")
#		jumping=true
#		jump_time.start()
#	if (jumping and jump):
#		velocity.y = -jump_time.get_time_left()*JUMP_VEL

	# Manage attack
	if (bot_sprite.get_current_animation() == "Slide"):
		can_attack = false
	elif (!attack):
		can_attack = true
	elif (can_attack and attack && !attacking):
		can_attack = false
		if (strong_slash and walk_up):
			strong_attack()
		else:
			attack()

	# Create attack damage hit
	if (create_sword):
		create_sword = false
		attack_spot.add_child(sword_hit.instance())

	# Synchronize both halfs animation
	if (is_attacking() and need_synchro):
		top_sprite.play(bot_sprite.get_current_animation())
		top_sprite.seek(bot_sprite.get_pos(),true)
		
	need_synchro = false
		
	# Manage sprite mirroring
	if (velocity.x>0):
		sees_left = false
	elif (velocity.x<0):
		sees_left = true
	if (sees_left):
		set_scale(Vector2(-1,1))
		direction = -1
	else:
		set_scale(Vector2(1,1))
		direction = 1

	# Dust states
	if (landed and (jumping or falling)):
		landed = false


	# Make sure attack fixes
	if (attacking and !is_attacking()):
		attacking = false
	#print("IA:" + str(is_attacking())+" A: "+str(attacking))

	# End Movement and Fixed Process
	

func stop(delta):
	var vsign = sign(velocity.x)
	var vx = abs(velocity.x)
	vx -= STOP_FORCE * delta
	if (vx<0):
		vx=0
		if (bot_sprite.get_current_animation() != "Idle" && bot_sprite.get_current_animation() != "Victory" && !walk_down && !jumping && !falling and !isdashing):
			if (not stopped and not jumping and not falling):
				create_dust("Brake")
				stopped = true
			bot_sprite.play("Idle")
			if (!is_attacking() and !noidle):
				top_sprite.play("Idle")
	velocity.x=vx*vsign

func attack():
		attacking = true
		if walk_down:
			controller.attackdmg = 1.5
		else:
			controller.attackdmg = 1
		if (top_sprite.get_current_animation() != "Attack" and top_sprite.get_current_animation() != "Attack2" and top_sprite.get_current_animation() != "Attack3"):
			top_sprite.play("Attack")
		elif (top_sprite.get_current_animation() == "Attack"):
			top_sprite.play("Attack2")
		elif (top_sprite.get_current_animation() == "Attack2"):
			top_sprite.play("Attack3")
		elif (top_sprite.get_current_animation() == "Attack3"):
			top_sprite.play("Attack")

func strong_attack():
		attacking = true
		controller.attackdmg = 2
		attack_spot.add_child(strong_hit.instance())
		top_sprite.play("StrongAttack")

func is_attacking():
	if (top_sprite.get_current_animation() == "Attack" or
		top_sprite.get_current_animation() == "Attack2" or
		top_sprite.get_current_animation() == "Attack3" or
		top_sprite.get_current_animation() == "StrongAttack"):
		return true
	else:
		return false

func slow_attack():
	if (not aspd):
		attacking = false

func fast_attack():
	if (aspd):
		attacking = false

func create_dust(type):
	var map = controller.current_map
	var instance = dust.instance()
	instance.play(type)
	map.add_child(instance)
	instance.set_global_pos(get_global_pos()+Vector2(0,32))
	instance.set_scale(Vector2(1 - 2*sees_left,1))

func _on_Hitbox_body_enter( body ):
	if (body extends hurtful_class):
		# Knockback some time maybe
		if (not dead and vulnerable):
			vulnerable = false
			effects.play("Invulnerable")
			controller.life_down()
	elif (body extends killer_class):
		if (not dead):
			controller.life_down()
			controller.life_down()

func death():
	waitingtodie = true
	bot_sprite.play("hurtfall")
	if landed:
		bot_sprite.play("die")
		top_sprite.play("None")
		waitingtodie = false
		dead = true
func die():
	
	
	var map = controller.current_map
	var instance = smoke_effects.instance()
	map.add_child(instance)
	get_node("/root/SoundManager").play_sfx("smoke",true)
	instance.play()
	instance.set_global_pos(get_global_pos()-Vector2(0,16))
	instance.set_scale(Vector2(1 - 2*sees_left,1))
	hide()
	top_sprite.stop()
	bot_sprite.stop()

func _on_Jump_timeout():
	if (jump):
		velocity.y = -JUMP_VEL
#	jumping = false




