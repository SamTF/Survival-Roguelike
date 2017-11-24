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
    dur = -1			#its durability - how many times it can be used before it breaks
}
var weaponKnife = {
    name = "knife",
    dmg = 2,
    mine = 0.5,
    rng = 1,
    dur = 5
}
var weaponCrossbow = {
    name = "crossbow",
    dmg = 1,
    mine = 0,
    rng = 5,
    dur = -1
}
#A database of all weapons
var weaponDB = [weaponPickaxe, weaponKnife, weaponCrossbow]
#The player's current weapon
var playerWeapon


func _ready():
	if level == 1:
		playerHP = 4
		food = 150
		playerWeapon = weaponDB[0]
		print(playerWeapon.name)

