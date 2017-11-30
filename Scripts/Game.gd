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
    mine = 1,
    rng = 1,
    speed = 0.01,
    dur = 20,
    Cdur = 20
}
var weaponMachete = {
    name = "machete",
    dmg = 2,
    mine = 0.2,
    rng = 1,
    speed = 1,
    dur = 20,
    Cdur = 20
}
var weaponCrossbow = {
    name = "crossbow",
    dmg = 1,
    mine = 0,
    rng = 5,
    speed = 1,
    dur = 10,
    Cdur = 10
}
var weaponEmpty = {
    name = "none",
    dmg = 0,
    mine = 0,
    rng = 0,
    speed = 0,
    dur = 0,
    Cdur = 0
}
#A database of all weapons
var weaponDB = [weaponPickaxe, weaponKnife, weaponMachete, weaponCrossbow]
#The player's current weapon
var playerWeapon


func _ready():
	if level == 1:
		playerHP = 4
		food = 150
		playerWeapon = weaponDB[0]
		#print(playerWeapon.name)

