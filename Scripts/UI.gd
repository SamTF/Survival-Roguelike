#This script controls all the UI functions
extends Node2D

### NODE VARS ######
#Loads the food label
onready var foodText = get_node("LabelFood")
#Loads the current level label
onready var currLevelText = get_node("LabelCurrentLevel")
#Loads the weapon label
onready var weaponText = get_node("LabelWeapon")
#Loads the Health sprite
onready var health = get_node("Health")
#Loads the Log label
onready var logText = utils.main_node.get_node("UI").get_node("LabelLog")
#Loads the player node
onready var player = utils.main_node.get_node("Player")
#Loads the Death Screen nodes
onready var level = get_node("Death Screen").get_node("LabelLevel")
onready var death = get_node("Death Screen").get_node("LabelDeath")
onready var highscore = get_node("Death Screen").get_node("LabelHighscore")
onready var deathAnim = get_node("Death Screen").get_node("BlackScreen/AnimationPlayer")
#Loads the Attcked nodes
onready var attackedAnim = get_node("Attacked/Claws/AnimationPlayer")

### UI VARS ######
var opacityWeapon
var GameOver = false

### INPUT VARS ######
var restart

func _ready():
	#Sets all the UI stuff to their respective values to prevent them from resetting
	foodText.set_text("Food: " + str(Game.food))
	health.set_frame(Game.playerHP - 1)
	currLevelText.set_text("day: " + str(Game.level))
	weaponText.set_text(Game.playerWeapon.name)
	opacityWeapon = float(Game.playerWeapon.Cdur)/float(Game.playerWeapon.dur)
	weaponText.set_opacity(opacityWeapon)
	
	#Func to catch input - used to restart the game
	set_process_input(true)

func _input(event):
	#If the restart key is pressed, the game restarts
	if event.is_action_pressed("restart"):
		Game.restart()

#Everytime the food value is changed, the text is updated
func _on_Player_foodChanged(food):
	foodText.set_text("food: " + str(food))

#Updates the health bar when the player's HP changes
func on_PlayerHP_Changed(HP):
	#When the player's health reaches zero, the health bar us deleted and the player's death function is called
	if HP < 1:
		health.queue_free()
		player.die("a zombie")
	#If the player still has health, then decrease it by one
	else:
		var frameID = HP - 1
		health.set_frame(frameID)

#Triggers when the player changes level - changes the day label to the current day
func _on_level_Changed(day):
	currLevelText.set_text("day: " + str(day))

#Changes the weapon name and resets opacity when the player changes weapon
func _on_weapon_Changed():
	weaponText.set_text(Game.playerWeapon.name)
	weaponText.set_opacity(1)

#Triggers when the player attacks - changes the opacity based on the current durability
func _on_weapon_Attack():
	#If the player has a weapon - prevents the "NONE" from fading
	if Game.playerWeapon.name != "none":
		opacityWeapon = float(Game.playerWeapon.Cdur)/float(Game.playerWeapon.dur)
		weaponText.set_opacity(opacityWeapon)

#Sets the death messages
func deathScreen(x, y):
	level.set_text("You survived for " + str(y) + " days")
	death.set_text("You were killed by " + str(x))
	highscore.set_text("Your best: " + str(Game.highscore) + " days")
	#This animation fades the screen slowly
	deathAnim.play("fadeOut")
	#Sets GameOver to true - used to know when to restart the game
	GameOver = true

func attacked():
	#Plays the claw animation
	attackedAnim.play("Flash")
	#Shakes the screen a bit - very immersive!
	get_tree().call_group(0, "Camera", "shake", 8, 0.2)