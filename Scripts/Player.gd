extends Area2D

#NODE VARIABLES
#The four directional ray casts
onready var rayUp = get_node("RayUp")
onready var rayRight = get_node("RayRight")
onready var rayDown = get_node("RayDown")
onready var rayLeft = get_node("RayLeft")
#Animation player
onready var anim = get_node("Sprite").get_node("Anim")
#Loads the Log label
onready var logText = utils.main_node.get_node("UI").get_node("LabelLog")

### RAYCAST VARIABLES ###
#Checks if the rays are colliding
var raycastUpColliding
var raycastRightColliding
var raycastDownColliding
var raycastLeftColliding
#Checks what the rays are detecting
var raycastUp
var raycastRight
var raycastDown
var raycastLeft

#DIRECTIONAL CONSTANTS
var direction = Vector2()
const UP = Vector2(0, -1)
const RIGHT = Vector2(1, 0)
const DOWN = Vector2(0, 1)
const LEFT = Vector2(-1, 0)

#INPUT VARIABLES
var moveUp
var moveRight
var moveDown
var moveLeft
var eat
var use

#POSITION VARIABLES
var pos = Vector2(0,0)
var newPos = Vector2(0,0)

#MOVEMENT VARIABLES
var canMove = true
var playerCanAttack = true
var isMoving = false
var isAttacked = false
var alive = true

#ACTION VARIABLES
#this are used to check what object is in the player's path and thus decide what action to take
var obstacle

#UI VARIABLES
var canEat = true
signal foodChanged
signal foodEat
signal healthChanged

func _ready():
	set_fixed_process(true)
	#we need this two assings to prevent the player pos from resetting on game start
	pos = Vector2(32, 192)
	newPos = Vector2(32, 192)
	set_pos(Vector2(32, 192))
	
func _fixed_process(delta):
	#Stores the current player position - very useful!
	pos = get_pos()

	#RAYCAST FUNCTIONS
	#Checks if the rays are colliding
	raycastUpColliding = rayUp.is_colliding()
	raycastRightColliding = rayRight.is_colliding()
	raycastDownColliding = rayDown.is_colliding()
	raycastLeftColliding = rayLeft.is_colliding()

	#Checks what the rays are detecting
	raycastUp = rayUp.get_collider()
	raycastRight = rayRight.get_collider()
	raycastDown = rayDown.get_collider()
	raycastLeft = rayLeft.get_collider()
	
	#Runs the ray functions for each directional ray
	#specifying the is_colliding, the get_collider, and the ray itself
	raycastFunc(raycastUpColliding, raycastUp, rayUp)
	raycastFunc(raycastRightColliding, raycastRight, rayRight)
	raycastFunc(raycastDownColliding, raycastDown, rayDown)
	raycastFunc(raycastLeftColliding, raycastLeft, rayLeft)
	

	
	#Shortcuts for the input actions
	moveUp = Input.is_action_pressed("ui_up")
	moveRight = Input.is_action_pressed("ui_right")
	moveDown = Input.is_action_pressed("ui_down")
	moveLeft = Input.is_action_pressed("ui_left")
	eat = Input.is_action_pressed("ui_accept")
	
	#if the amount of food reaches zero, the player dies by starvation
	if Game.food == 0:
		die("starvation")
	
	#checks if the player is moving
	isMoving = moveLeft or moveRight or moveUp or moveDown or eat
	#resets the direction
	direction = Vector2(0,0)
	
	#If the player isn't moving, he now becomes able to
	if not isMoving: canMove = true
	
	#INPUT EVENTS
	#Triggers if the player has pressed a key and is able to move and is not being attacked
	if isMoving and canMove and not isAttacked:
		#if the player has pressed a key, he can't move any farther
		canMove = false
		
		#Prints the ray information
		#raycastPrint()
		
		#!!! VERY NICE ALTERNATIVE TO SIGNALS !!!
		#This calls the "enemyTurn" function on ALL nodes in the "enemy" group
		get_tree().call_group(0, "enemy", "enemyTurn", self)
	
	#Checks in which direction the player is moving
	#the "and pos ..." ensures that the player may only move once the previous movement has ended
		###UP#####
		if moveUp and pos == newPos:
			direction = UP
			
			#checks if the path is unblocked
			if rayUp.obstacle == "none":
				#Calls the "walk" function with the direction UP
				walk(UP)
			#If the item in the way is food, the player can still move
			elif rayUp.obstacle == "Food":
				#Calls the "walkFood" function with the direction UP
				walkFood(UP)
			#If the obstacle is a wall or an enemy, the player hits it
			elif rayUp.obstacle == "Wall":
				attack(raycastUp)
			elif rayUp.obstacle == "Enemy" and playerCanAttack:
				#Calls the "attack" function with the object the raycast hit if the player can attack
				attack(raycastUp)
			#if the path is blocked, print what blocked the path
			else:
				print("Path blocked by " + str(rayUp.obstacle))

		###DOWN#####
		elif moveDown and pos == newPos:
			direction = DOWN
			#None
			if rayDown.obstacle == "none":
				walk(DOWN)
			#Food
			elif rayDown.obstacle == "Food":
				walkFood(DOWN)
			#Wall
			elif rayDown.obstacle == "Wall":
				attack(raycastDown)
			#Enemy
			elif rayDown.obstacle == "Enemy" and playerCanAttack:
				attack(raycastDown)
			#Else
			else:
				print("Path blocked by " + str(rayDown.obstacle))
		
		###LEFT#####
		elif moveLeft and pos == newPos:
			direction = LEFT
			#None
			if rayLeft.obstacle == "none":
				walk(LEFT)
			#Food
			elif rayLeft.obstacle == "Food":
				walkFood(LEFT)
			#Wall
			elif rayLeft.obstacle == "Wall":
				attack(raycastLeft)
			#Enemy	
			elif rayLeft.obstacle == "Enemy" and playerCanAttack:
				attack(raycastLeft)
			#Else
			else:
				print("Path blocked by " + str(rayLeft.obstacle))
		
		###RIGHT#####
		elif moveRight and pos == newPos:
			direction = RIGHT
			#None
			if rayRight.obstacle == "none":
				walk(RIGHT)
			#Food
			elif rayRight.obstacle == "Food":
				walkFood(RIGHT)
			#Wall
			elif rayRight.obstacle == "Wall":
				attack(raycastRight)
			#Enemy
			elif rayRight.obstacle == "Enemy" and playerCanAttack:
				attack(raycastRight)
			#Else
			else:
				print("Path blocked by " + str(rayRight.obstacle))
	
	#The player can spend 50 food to regain one heart, which counts as an action
	#Triggers when the eat key is pressed and if the player can eat
	if eat and canEat:
		canEat = false
		#if the player has enough food and doesn't have max HP
		if Game.food > 49 and Game.playerHP < 4:
			#removes 50 food from the player and adds on HP
			Game.food -= 50
			Game.playerHP += 1
			#Plays the fruit sound effect from the Audio Player
			AudioPlayer.play("scavengers_fruit")

			#Tells the UI to update the health bar and food counter
			#!!! THIS FUNCTION IS REALLY AWESOME PLEASE REMEMBER THIS !!!
			#Args: 0, groupName, funcName, variables
			get_tree().call_group(0, "UI", "on_PlayerHP_Changed", Game.playerHP)
			emit_signal("foodChanged", Game.food)
			#Tells the UI to add a message saying how much food was removed
			logText.set_text("-50 food")
			yield(utils.create_timer(1), "timeout")
			logText.set_text("")
			#Allows the player to eat again
			canEat = true

	#Moves the player smoothly
	var motion = (newPos - pos) * 0.5
	set_pos(pos + motion)

################################
### THE ACTION FUNCTIONS #######
#These functions are the player's actions: walking, walking into food, mining a wall, attacking an enemy

#Walk action - takes a direction argument
func walk(direction):

	#defines what the new position will be
	newPos = (pos + (direction * 32))
	#subtracts one food from the player
	Game.food -= 1
	#Emits a signal to update the food label
	emit_signal("foodChanged", Game.food)
	#Plays the movement sound from the AudioPlayer
	AudioPlayer.play("scavengers_footstep")

#Walking into food - same as above but the player doesn't lose food
func walkFood(direction):
	#Simply moves the player without subtracting food
	newPos = (pos + (direction * 32))
	#Plays the movement sound from the AudioPlayer
	AudioPlayer.play("scavengers_footstep")

#Attack - when the player hits an object (either a wall or an enemy)
func attack(object):
	#if the object is a wall, then the player consumes food to attack it
	if object.is_in_group("tileWalls"):
		Game.food -= 1
		#Emits a signal to update the food label
		emit_signal("foodChanged", Game.food)

	#The player can't attack again until the current attack is finished - prevents the player from attacking twice before the enemy can react
	playerCanAttack = false

	#plays the attack animation
	anim.play("Attack")
	#calls the takeDamage func on the enemy
	object.takeDamage()
	#Plays the chopping sound from the AudioPlayer
	AudioPlayer.play("scavengers_chop")
	#Shakes the screen a bit - very immersive!
	get_tree().call_group(0, "Camera", "shake", 1, 0.13)
	#Decreases the weapon's current durability by one
	Game.playerWeapon.Cdur -= 1
	#Breaks the weapon if the durability has reached 0
	if Game.playerWeapon.Cdur < 1:
		#sets the weapon to "none"
		Game.playerWeapon = Game.weaponDB[4]
		get_tree().call_group(0, "UI", "_on_weapon_Changed")
	#Updates the weapon label on the UI
	get_tree().call_group(0, "UI", "_on_weapon_Attack")
	#Waits before reseting the player's ability to attack depending on the current weapon's speed
	yield(utils.create_timer(Game.playerWeapon.speed), "timeout")
	playerCanAttack = true

#Ray functions for each directional ray
#specifying the is_colliding, the get_collider, and the ray itself
#Detecs if ray has collided with something, and if so, stores the name of the target directly on the ray itself
func raycastFunc(x, y, z):
	
	#If the ray has collided with something
	if x and y != null:
		#print(y.get_name())
		
		#Checks which group the target is in and sets that as the obstacle
		if y.is_in_group("outerWalls"):
			z.obstacle = "OuterWall"
		elif y.is_in_group("tileWalls"):
			z.obstacle = "Wall"
		elif y.is_in_group("enemy"):
			z.obstacle = "Enemy"
		elif y.is_in_group("Food"):
			z.obstacle = "Food"
		elif y.is_in_group("Weapons"):
			z.obstacle = "none"
	
	#if it hasn't collided with anything, the obstacle is set to none
	else:
		z.obstacle = "none"

#Prints the raycast information
func raycastPrint():
	print("==== ENVIRONMENT INFO ====")
	print("UP: " + str(rayUp.obstacle))
	print("RIGHT: " + str(rayRight.obstacle))
	print("DOWN: " + str(rayDown.obstacle))
	print("LEFT: " + str(rayLeft.obstacle))

#This func gets called when the player's HP reaches 0, X is what killed the player
func die(x):
	alive = false
	set_opacity(0)
	var CoD = x
	#Days survived is the current game level
	var daysSurvived = Game.level
	#Updates the highscore is the current score is bigger than the highscore
	if daysSurvived > Game.highscore:
		Game.highscore = daysSurvived
		Game.saveHighscore()
	#This calls the "deathScreen" function on the UI node, printing the Cause of Death and the days survived
	get_tree().call_group(0, "UI", "deathScreen", CoD, daysSurvived)
	#this yield is used to prevent the game from crashing
	yield(utils.create_timer(1.1), "timeout")
	queue_free()




