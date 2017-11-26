#This script controls all the UI functions
extends Node2D

#Loads the food label
onready var foodText = get_node("LabelFood")
#Loads the current level label
onready var currLevelText = get_node("LabelCurrentLevel")
#Loads the Health sprite
onready var health = get_node("Health")
#Loads the Log label
onready var logText = utils.main_node.get_node("UI").get_node("LabelLog")
#Loads the player node
onready var player = utils.main_node.get_node("Player")
#Loads the Death Screen nodes
onready var level = get_node("Death Screen").get_node("LabelLevel")
onready var death = get_node("Death Screen").get_node("LabelDeath")
onready var deathAnim = get_node("Death Screen").get_node("BlackScreen/AnimationPlayer")
#Loads the Attcked nodes
onready var attackedAnim = get_node("Attacked/Claws/AnimationPlayer")


func _ready():
	#Sets all the UI stuff to their respective values to prevent them from resetting
	foodText.set_text("Food: " + str(Game.food))
	health.set_frame(Game.playerHP - 1)
	currLevelText.set_text("day: " + str(Game.level))

#Everytime the food value is changed, the text is updated
func _on_Player_foodChanged(food):
	foodText.set_text("food: " + str(food))

func on_PlayerHP_Changed(HP):
	#When the player's health reaches zero, the health bar us deleted and the player's death function is called
	if HP < 1:
		health.queue_free()
		player.die("a zombie")
	#If the player still has health, then decrease it by one
	else:
		var frameID = HP - 1
		health.set_frame(frameID)

#Triggers when the player changes level
func _on_level_Changed(day):
	print("LEVEL CHANGED")
	currLevelText.set_text("day: " + str(day))

#Sets the death messages
func deathScreen(x, y):
	level.set_text("You survived for " + str(y) + " days")
	death.set_text("You were killed by " + str(x))
	#This animation fades the screen slowly
	deathAnim.play("fadeOut")

func attacked():
	#Plays the claw animation
	attackedAnim.play("Flash")
	#Shakes the screen a bit - very immersive!
	get_tree().call_group(0, "Camera", "shake", 8, 0.2)