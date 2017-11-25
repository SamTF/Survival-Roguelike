extends Area2D

#Loads the sprite
onready var sprite = get_node("Sprite")
onready var anim = get_node("Sprite/AnimationPlayer")
onready var hitbox = get_node("CollisionShape2D")

var weaponItem

func _ready():
	randomize()
	#Sets a random framde for the sprite (each frame being a different weapon)
	var frameID = round(rand_range(0,3))
	sprite.set_frame(frameID)
	#sets the weapon class to match the sprite's frame
	weaponItem = Game.weaponDB[frameID]
	print(weaponItem)

func _on_area_enter( area ):
	print("AAAAAAAAAAAAAAAA")
	#if the area that entered the item was the player and the item has not been destroyed already
	if area.is_in_group("Player"):

		#adds the new weapon to the player
		Game.playerWeapon = weaponItem
		#Tells the sprite to play the pickup animation
		anim.play("pickup")
		#destroys the hitbox to prevent the func from triggering multiple times
		hitbox.queue_free()
