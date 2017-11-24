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

#RAYCAST VARIABLES
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
#The obstacle variables
var obstacleUp
var obstacleRight
var obstacleDown
var obstacleLeft

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

#POSITION VARIABLES
var pos = Vector2(0,0)
var newPos = Vector2(0,0)

#MOVEMENT VARIABLES
var canMove = true
var isMoving = false
var isAttacked = false
var alive = true

#ACTION VARIABLES
#this are used to check what object is in the player's path and thus decide what action to take
var obstacle
var action

#UI VARIABLES
var canEat = true
signal foodChanged
signal foodEat
signal healthChanged

func _ready():
	set_fixed_process(true)
	#we need this two assings to prevent the player pos from resetting on game start
	pos = Vector2(48, 208)
	newPos = Vector2(48, 208)
	set_pos(Vector2(48, 208))
	
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
	
	#checks if the player is moving
	isMoving = moveLeft or moveRight or moveUp or moveDown or eat
	#resets the direction
	direction = Vector2(0,0)
	
	#If the player isn't able to move, he now becomes able to
	if not isMoving: canMove = true
	
	#INPUT EVENTS
	#Triggers if the player has pressed a key and is able to move and is not being attacked
	if isMoving and canMove and not isAttacked:
		#if the player has pressed a key, he can't move any farther
		canMove = false
		
		#Prints the ray information
		#raycastPrint()
		
		#This calls the "movement" function on ALL nodes in the "enemy" group
		get_tree().call_group(0, "enemy", "movement", self)
	
	#Checks in which direction the player is moving
	#the "and pos ..." ensures that the player may only move once the previous movement has ended
		if moveUp and pos == newPos:
			direction = UP
			
			#checks if the path is unblocked
			if rayUp.obstacle == "none":
			#defines what the new position will be
				newPos = (pos + (direction * 32))
				#subtracts one food from the player
				Game.food -= 1
				#Emits a signal to update the food label
				emit_signal("foodChanged", Game.food)
			#If the item in the way is food, the player can still move
			elif rayUp.obstacle == "Food":
				newPos = (pos + (direction * 32))
			#If the item is a wall, the player hits it
			elif rayUp.obstacle == "Wall":
				Game.food -= 1
				#Emits a signal to update the food label
				emit_signal("foodChanged", Game.food)
				anim.play("Attack")
				raycastUp.takeDamage()
			#If the obstacle is an enemy, attack him
			elif rayUp.obstacle == "Enemy":
				#plays the attack animation
				anim.play("Attack")
				#calls the takeDamage func on the enemy
				raycastUp.takeDamage()
			#if the path is blocked, print what blocked the path
			else:
				print("Path blocked by " + str(rayUp.obstacle))

		elif moveDown and pos == newPos:
			direction = DOWN
			if rayDown.obstacle == "none":
				newPos = (pos + (direction * 32))
				Game.food -= 1
				emit_signal("foodChanged", Game.food)
			elif rayDown.obstacle == "Food":
				newPos = (pos + (direction * 32))
			elif rayDown.obstacle == "Wall":
				Game.food -= 1
				emit_signal("foodChanged", Game.food)
				anim.play("Attack")
				raycastDown.takeDamage()
			elif rayDown.obstacle == "Enemy":
				anim.play("Attack")
				raycastDown.takeDamage()
			else:
				print("Path blocked by " + str(rayDown.obstacle))
		
		elif moveLeft and pos == newPos:
			direction = LEFT
			if rayLeft.obstacle == "none":
				newPos = (pos + (direction * 32))
				Game.food -= 1
				emit_signal("foodChanged", Game.food)
			elif rayLeft.obstacle == "Food":
				newPos = (pos + (direction * 32))
			elif rayLeft.obstacle == "Wall":
				Game.food -= 1
				emit_signal("foodChanged", Game.food)
				anim.play("Attack")
				raycastLeft.takeDamage()
			elif rayLeft.obstacle == "Enemy":
				anim.play("Attack")
				raycastLeft.takeDamage()
			else:
				print("Path blocked by " + str(rayLeft.obstacle))
		
		elif moveRight and pos == newPos:
			direction = RIGHT
			if rayRight.obstacle == "none":
				newPos = (pos + (direction * 32))
				Game.food -= 1
				emit_signal("foodChanged", Game.food)
			elif rayRight.obstacle == "Food":
				newPos = (pos + (direction * 32))
			elif rayRight.obstacle == "Wall":
				Game.food -= 1
				emit_signal("foodChanged", Game.food)
				anim.play("Attack")
				raycastRight.takeDamage()
			elif rayRight.obstacle == "Enemy":
				anim.play("Attack")
				raycastRight.takeDamage()
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
	#This calls the "deathScreen" function on the UI node, printing the Cause of Death and the days survived
	get_tree().call_group(0, "UI", "deathScreen", CoD, daysSurvived)
	#this yield is used to prevent the game from crashing
	yield(utils.create_timer(1.1), "timeout")
	queue_free()



