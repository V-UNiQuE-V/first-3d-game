extends CharacterBody3D


func _ready():
	# run code once on our player
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
 
# input checks related to UI or general things like toggling mouse, game full screen put these in unhandled_input()
func _unhandled_input(event): # Mouse Motion
	if event is InputEventMouseMotion:
		# to adjust the rotation of camera we divide the rel. dist or multiply with small no. (lower sensitive -> lower the value)
		rotation_degrees.y -= event.relative.x * 0.5
		# get_node("Camera3D") same as $Camera3D
		%Camera3D.rotation_degrees.x -= event.relative.y * 0.2
		# Limit the camera rotation using clamp(val to limit, min, max)
		%Camera3D.rotation_degrees.x = clamp(
			%Camera3D.rotation_degrees.x, -60.0, 60.0
		)
	elif event.is_action_pressed("ui_cancel"): 
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _physics_process(delta): # write on each frame
	const SPEED = 5.5
	
	# movement code
	
	# input dir of player in 2D
	var input_dir_2D = Input.get_vector(
		"move_left", "move_right", "move_forward", "move_back"
	)
	# when character turns around i.e. rotates in 3D the z-axis it also moves in (x,y).
	var input_dir_3D = Vector3(
		# X component in 3D - 2D'S X, Z component in 3D - 2D's Y
		input_dir_2D.x, 0.0, input_dir_2D.y
	)
	
	# Transform(collection of vector represents ori, pos, scale of node) the movement to be relative to the camera  orientation
	# basis(co-ordinate system of a node) of character i.e. based on where character looks along that axis we move.
	
	var direction = transform.basis * input_dir_3D
	
	# before changing orientation of input dir let's see how character moves without the input dir relative to the player.
	
	# velocity - 3D dir vector scales at the speed we want to move at.
	# on jump & fall since the 3d input dir has 0 on vertical axis so it doesn't do anything thus split the line and change vals component by component
	#velocity = input_dir_3D * SPEED
	#velocity.x = input_dir_3D.x * SPEED
	#velocity.z = input_dir_3D.z * SPEED
	
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED
	
	# add gravity (downward acceleration) for it to fall
	
	# m/s <- m/s^2 by x with time(s)
	velocity.y -= 20.0 * delta # delta - time elapsed between prev. frame.
	# jump movement only when character jumps from the floor
	# based on the amt.of time jump key pressed down we make it jump higher i.e. check if jump key is released when character is up so reset vertical velocity.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = 10.0
	elif Input.is_action_just_released("jump") and velocity.y > 0.0: 
		velocity.y = 0.0
	
	move_and_slide()
	
	#if Input.is_action_just_pressed("shoot"):
	if Input.is_action_pressed("shoot") and %Timer.is_stopped(): # as long as pressed shoot bullets every frame.
		shoot_bullet()


func shoot_bullet():
	# load bullet scene from file system
	# preload - loads file once and replaces the fn virtually with loaded resource.
	const BULLET_3D = preload("res://player/bullet_3d.tscn")
	var new_bullet = BULLET_3D.instantiate()
	%Marker3D.add_child(new_bullet)
	# move & orient bullet to the marker 
	new_bullet.global_transform = %Marker3D.global_transform
	
	## each time bullet shoots start the timer. While timer is running we prevent player to shoot
	%Timer.start()
