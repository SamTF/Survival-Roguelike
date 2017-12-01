extends Area2D

#CHARACTER VARIABLES
var health = 2
var EnemyType

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
var moveDir = 0
var canAttack = true

func _ready():
	#The enemy type is equal to its frame - used to determine the AI type
	EnemyType = get_node("Sprite").get_frame()
	print("Enemy Type: " + str(EnemyType))
	set_fixed_process(true)
	pos = get_pos()
	newPos = pos
	
func _fixed_process(delta):
	#Stores the current position - very useful!
	pos = get_pos()
	
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
	
	#MOVEMENT FUNCTIONS
	var motion = (newPos - pos) * 0.5
	set_pos(pos + motion)

#Ray functions for each directional ray
#specifying the is_colliding, the get_collider, and the ray itself
#Detecs if ray has collided with something, and if so, stores the name of the target directly on the ray itself
func raycastFunc(x, y, z):
	
	#If the ray has collided with something
	if x and y != null:
		#Checks which group the target is in and sets that as the obstacle
		if y.is_in_group("outerWalls"):
			z.obstacle = "OuterWall"
		elif y.is_in_group("tileWalls"):
			z.obstacle = "Wall"
		elif y.is_in_group("Player"):
			z.obstacle = "Player"
		elif y.is_in_group("Food"):
			z.obstacle = "none"		#enemies ignore food and can walk thru it
		elif y.is_in_group("Exit"):
			z.obstacle = "Exit"
		elif y.is_in_group("enemy"):
			z.obstacle = "Enemy"
	#if it hasn't collided with anything, the obstacle is set to none
	else:
		z.obstacle = "none"
	

#Prints the raycast information
func raycastPrint():
	print("==== ENEMY AI INFO ====")
	print("UP: " + str(rayUp.obstacle))
	print("RIGHT: " + str(rayRight.obstacle))
	print("DOWN: " + str(rayDown.obstacle))
	print("LEFT: " + str(rayLeft.obstacle))

#This func is called whenever the player moves
func enemyTurn(x):
	#Gets the player's position
	var playerPos = player.get_pos()
	#prints the raycast info
	raycastPrint()
	#waits for the player to be in position
	yield(utils.create_timer(0.3), "timeout")

	#Calls the move function depending on the type of enemy
	if EnemyType == 12: moveRand()
	elif EnemyType == 55: moveStalk(pos, playerPos)

	#If the player is beside the enemy, and the enemy can attack, and the player is alive, and the player has finished being attacked, the enemy will attack the player
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
		#Flashes the Player attacked sprite
		get_tree().call_group(0, "UI", "attacked")
	
		#This is used to prevent the player from being attacked twice in a row
		yield(utils.create_timer(1), "timeout")
		#re-enables the enemy's ability to attack after the previous attack is over
		canAttack = true
		#States that the player is no longer being attacked
		player.isAttacked = false

func moveRand():
	######THE ENEMY'S MOVEMENT################################
	#TYPE: RANDOM
	randomize()
	
	#If the enemy is adjacent to the player: he will not move and instead will attack the player
	if rayUp.obstacle == "Player" or rayRight.obstacle == "Player" or rayDown.obstacle == "Player" or rayLeft.obstacle == "Player":
		moveDir = 0
		direction = Vector2(0, 0)
		
	#If the enemy is not adjacent to the player then he will move as normal
	else:
		moveDir = round(rand_range(1,4))

	#print("MoveDir: " + str(moveDir))

	#Move up if the RNG is one and there's no obstacle there
	if moveDir == 1 and rayUp.obstacle == "none":
		#Sets the direction in which the enemy will move
		direction = UP
	#If this direction is blocked: try another until an unblocked direction is found. If none if found then the enemy doesn't move
	elif moveDir == 1 and rayUp.obstacle != "none":
		if rayRight.obstacle == "none":
			direction = RIGHT
		elif rayLeft.obstacle == "none":
			direction = LEFT
		elif rayDown.obstacle == "none":
			direction = DOWN
		else:
			direction = Vector2(0,0)

	#Move right if the RNG is one and there's no obstacle there
	if moveDir == 2 and rayRight.obstacle == "none":
		direction = RIGHT
	elif moveDir == 2 and rayRight.obstacle != "none":
		if rayUp.obstacle == "none":
			direction = UP
		elif rayLeft.obstacle == "none":
			direction = LEFT
		elif rayDown.obstacle == "none":
			direction = DOWN
		else:
			direction = Vector2(0,0)
	
	#Move down if the RNG is one and there's no obstacle there
	if moveDir == 3 and rayDown.obstacle == "none":
		direction = DOWN
	elif moveDir == 3 and rayDown.obstacle != "none":
		if rayRight.obstacle == "none":
			direction = RIGHT
		elif rayLeft.obstacle == "none":
			direction = LEFT
		elif rayUp.obstacle == "none":
			direction = UP
		else:
			direction = Vector2(0,0)
	
	#Move Left if the RNG is one and there's no obstacle there
	if moveDir == 4 and rayLeft.obstacle == "none":
		direction = LEFT
	elif moveDir == 4 and rayLeft.obstacle != "none":
		if rayRight.obstacle == "none":
			direction = RIGHT
		elif rayUp.obstacle == "none":
			direction = UP
		elif rayDown.obstacle == "none":
			direction = DOWN
		else:
			direction = Vector2(0,0)

	newPos = (pos + (direction * 32))
	#print("Direction: " + str(direction))

func moveStalk(pos, playerPos):
	######THE ENEMY'S MOVEMENT################################
	#TYPE: STALK THE PLAYER
	print("Enemy pos: " + str(pos))
	print("Player pos: " + str(playerPos))

	#If the enemy is adjacent to the player: he will not move and instead will attack the player
	if rayUp.obstacle == "Player" or rayRight.obstacle == "Player" or rayDown.obstacle == "Player" or rayLeft.obstacle == "Player":
		direction = Vector2(0, 0)

	#If the player is above the enemy, the enemy will move up
	elif playerPos.y < pos.y and rayUp.obstacle == "none":
		#Sets the direction in which the enemy will move
		direction = UP
	#If the player is below the enemy, the enemy will move down
	elif playerPos.y > pos.y and rayDown.obstacle == "none":
		direction = DOWN
	#If the player is to the left of the enemy, the enemy will move left
	elif playerPos.x < pos.x and rayLeft.obstacle == "none":
		direction = LEFT
	#If the player is to the right of the enemy, the enemy will move right
	elif playerPos.x > pos.x and rayRight.obstacle == "none":
		direction = RIGHT
	#If the enemy is stuck he won't move - prevents the game from crashing!
	else:
		direction = Vector2(0, 0)
	
	#Actually moves the enemy in the designated direction
	newPos = (pos + (direction * 32))

func attack():
	anim.play("Attack")
	#Plays the enemy sound effect from the Audio Player
	AudioPlayer.play("scavengers_enemy")

#Triggers when the enemy is attacked
func takeDamage():
	#Gets the damage of the player's current weapon and substracts that from the enemy's HP
	health -= Game.playerWeapon.dmg
	#Plays the enemy sound effect from the Audio Player
	AudioPlayer.play("scavengers_enemy")
	#if the enemy's HP is bigger than 0 it fades a bit
	if health > 0:
		set_opacity(health/2.0)
	#if it's 0 or less then the enemy is deleted
	else:
		queue_free()