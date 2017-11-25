extends Area2D

#Loads the sprite
onready var sprite = get_node("Sprite")
#Loads the sprite animation player
onready var anim = get_node("Sprite").get_node("AnimationPlayer")
#Loads the Log label
onready var logText = utils.main_node.get_node("UI").get_node("LabelLog")

var destroyed = false

func _ready():
	randomize()
	var frameID = round(rand_range(1,2)) + 17
	sprite.set_frame(frameID)

func _on_area_enter( area ):
	#if the area that entered the item was the player and the item has not been destroyed already
	if area.is_in_group("Player") and not destroyed:
		#adds ten food to the player
		Game.food += 20
		#Emits a signal to update the food label
		area.emit_signal("foodChanged", Game.food)
		#Tells the sprite to play the pickup animation
		anim.play("pickup")
		
		#Plays the eating sound from the AudioPlayer
		if sprite.get_frame() == 19:
			#Plays the fruit sound effect if the fruit is the current frame
			AudioPlayer.play("scavengers_fruit")
		else:
			AudioPlayer.play("scavengers_soda")
		print("om nom nom")
		
		
		#The following lines are used to remove the food from the map without crashing the fucking game
		get_node("CollisionShape2D").queue_free()
		#set_opacity(0)
		#Flashes the +food text
		logText.set_text("+20 food")
		yield(utils.create_timer(1), "timeout")
		logText.set_text("")
		destroyed = true