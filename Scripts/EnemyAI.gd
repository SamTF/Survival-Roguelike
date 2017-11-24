extends Area2D

#NODE VARIABLES
#The four directional ray casts
onready var rayUp = get_node("RayUp")
onready var rayRight = get_node("RayRight")
onready var rayDown = get_node("RayDown")
onready var rayLeft = get_node("RayLeft")
#Animation player
onready var anim = get_node("Sprite").get_node("Anim")
#Player node
onready var player = utils.main_node.get_node("Player")

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

#POSITION VARIABLES
var pos = Vector2(0,0)
var newPos = Vector2(0,0)

#MOVEMENT VARIABLES
var canMove = true
var isMoving = false
var canAttack = true

#ACTION VARIABLES
#this are used to check what object is in the player's path and thus decide what action to take
var obstacle

#UI VARIABLES
var health = 2
signal attacked


func _ready():
	set_fixed_process(true)
	pos = get_pos()
	newPos = pos
	
	

func _fixed_process(delta):
	#Stores the current player position - very useful!
	pos = get_pos()

	#RAYCAST FUNCTIONS
	#Type Mask for Area2D
	#rayUp.set_type_mask(16)
	#rayRight.set_type_mask(16)
	#rayDown.set_type_mask(16)
	#rayLeft.set_type_mask(16)
	
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
		elif y.is_in_group("Player"):
			z.obstacle = "Player"
		elif y.is_in_group("Food"):
			z.obstacle = "Food"
	#if it hasn't collided with anything, the obstacle is set to none
	else:
		z.obstacle = "none"
	

#Prints the raycast information
func raycastPrint():
	print("==== ENEMY AI INFO ====")
	if raycastUp != null:
		print("UP: " + str(rayUp.obstacle))
	if raycastRight != null:
		print("RIGHT: " + str(rayRight.obstacle))
	if raycastDown != null:
		print("DOWN: " + str(rayDown.obstacle))
	if raycastLeft != null:
		print("LEFT: " + str(rayLeft.obstacle))

#This func is called whenever the player moves
func movement(x):
	raycastPrint()
	#print(x.pos)
	#print("MOVEMENT")
	#waits for the player to be in position
	yield(utils.create_timer(0.3), "timeout")
	#If the player is beside the enemy, and the enemy can attack, and the player is alive, and the player has finished being attacked, and the player is not on the exit, the enemy will attack the player
	if rayUp.obstacle == "Player" or rayRight.obstacle == "Player" or rayDown.obstacle == "Player" or rayLeft.obstacle == "Player" and canAttack and player.alive and not player.isAttacked and player.get_pos() != Vector2(208, 64):
		#disables the enemy's attack until the current attack is complete
		canAttack = false
		#States that the player is being attacked
		player.isAttacked = true
		#attacks the player
		attack()
		#lowers the player's HP by one
		Game.playerHP -= 1
		#calls the function in the UI node to update the HP
		get_tree().call_group(0, "UI", "on_PlayerHP_Changed", Game.playerHP)
		#Plays the attacked animation on the player
		player.anim.play("Attacked")
	
	#This is used to prevent the player from being attacked twice in a row
	yield(utils.create_timer(1), "timeout")
	#re-enables the enemy's ability to attack after the previous attack is over
	canAttack = true
	#States that the player is no longer being attacked
	player.isAttacked = false

func attack():
	anim.play("Attack")

#Triggers when the enemy is attacked
func takeDamage():
	#Gets the damage of the player's current weapon and substracts that from the enemy's HP
	health -= Game.playerWeapon.dmg
	#if the enemy's HP is bigger than 0 it fades a bit
	if health > 0:
		set_opacity(0.5)
	#if it's 0 or less then the enemy is deleted
	else:
		queue_free()
	print(health)