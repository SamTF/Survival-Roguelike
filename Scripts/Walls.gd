extends Area2D

#Gets the wall node
onready var wall = get_node("Sprite")
var damage = 0
var opacity = 1

func _ready():
	randomize()
	#var used to set a random frame
	var frameID = round(rand_range(1, 8))
	#man fuck this spreadsheet
	if frameID == 5:
		frameID = 7
	elif frameID == 6:
		frameID = 9
	elif frameID == 7:
		frameID = 10
	elif frameID == 8:
		frameID = 11
	
	wall.set_frame(20+frameID)
	

func takeDamage():
	#Gets the damage of the player's current weapon and adds it as damage to the wall
	damage += Game.playerWeapon.mine
	#decreases the opacity by one third per hit
	opacity -= 0.3 * Game.playerWeapon.mine
	wall.set_opacity(opacity)
	
	if damage > 2:
		#The following lines are used to remove the food from the map without crashing the fucking game
		yield(utils.create_timer(0.2), "timeout")
		queue_free()
		#get_node("CollisionShape2D").queue_free()
		#get_node("Sprite").queue_free()
