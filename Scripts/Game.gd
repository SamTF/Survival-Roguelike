extends Node

#This stores in important variables needed by many scenes
#the current level
var level = 1
#the player's health
var playerHP
#the player's store of food
var food
#The player's weapons
var weaponPickaxe = {
    name = "pickaxe",	#the name of the weapon
    dmg = 1,			#the damage it does to enemies
    mine = 1,			#the mining damage - damage to blocks
    rng = 1,			#its range
    speed = 1,			#attack cooldown (the slower the better)
    dur = 50,			#its maximum durability - how many times it can be used before it breaks
    Cdur = 50			#the Current durability of the weapon
}
var weaponKnife = {
    name = "knife",
    dmg = 1,
    mine = 0.3,
    rng = 1,
    speed = 0.01,
    dur = 20,
    Cdur = 20
}
var weaponMachete = {
    name = "machete",
    dmg = 2,
    mine = 0.3,
    rng = 1,
    speed = 1,
    dur = 20,
    Cdur = 20
}
var weaponCrossbow = {
    name = "crossbow",
    dmg = 1,
    mine = 0.3,
    rng = 5,
    speed = 1,
    dur = 10,
    Cdur = 10
}
var weaponEmpty = {
    name = "none",
    dmg = 0.5,
    mine = 0.2,
    rng = 1,
    speed = 0,
    dur = 0,
    Cdur = 0
}
#A database of all weapons
var weaponDB = [weaponPickaxe, weaponKnife, weaponMachete, weaponCrossbow, weaponEmpty]
#The player's current weapon
var playerWeapon

#The player's highscore
var highscore = 0 #setget setHighscore
#The engine automatically get's the user's filepath which we will use to store this variable
const filepath = "user://highscore.data"

func _ready():
	loadHighscore()
	
	if level == 1:
		playerHP = 4
		food = 150
		playerWeapon = weaponDB[0]
		#print(playerWeapon.name)

#This func is used to restart the game to level 1
func restart():
	level = 1
	playerHP = 4
	food = 150
	playerWeapon = weaponDB[0]
	playerWeapon.Cdur = playerWeapon.dur
	get_tree().reload_current_scene()

#This func is used to load the highscore from the file
func loadHighscore():
	var file = File.new()
	#ends the loop if the file doesn't exist
	if not file.file_exists(filepath): return
	file.open(filepath, File.READ)
	highscore = file.get_var()
	file.close()

#This func is used to save the highscore to a file
func saveHighscore():
	var file = File.new()
	file.open(filepath, File.WRITE)
	file.store_var(highscore)
	file.close()





