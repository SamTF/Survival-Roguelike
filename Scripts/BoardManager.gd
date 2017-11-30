#script: BoardManager
#used to randomly create the levels

extends Node

#Scenes to instance
var wallScene = preload("res://Scenes/Walls.tscn")
var outerWallScene = preload("res://Scenes/OuterWalls.tscn")
var food = preload("res://Scenes/Food.tscn")
var enemy1 = preload("res://Scenes/Enemy1.tscn")
var enemy2 = preload("res://Scenes/Enemy2.tscn")
var enemy3 = preload("res://Scenes/Enemy3.tscn")
var weapon = preload("res://Scenes/Weapons.tscn")

export var columns = 8
export var rows = 8
var gridPositions = []

onready var nodeFloor = get_node("Floor")
onready var floorTiles = nodeFloor.get_node("TileFloor")
onready var nodeItems = get_node("Items")

func _ready():
	#LEVEL STUFF
	var level = Game.level

	#calculates the current difficulty
	var difficulty = floor((log(level)/log(2)))
	Globals.set("difficulty", difficulty)
	print("====== LEVEL INFO ======")
	print("LEVEL: " + str(level))
	print("DIFFICULTY: " + str(difficulty))
	print("=========================")

	
	genFloor()
	genOuterWalls()
	genUnits()
	genWalls(round(rand_range(6, 12)))
	genItems(round(rand_range(1, 3)))
	genEnemies(difficulty)
	#print(exp(1)) #USE THIS TO SCALE DIFFICULTY MORE HARSHLY

func genFloor():
	randomize()
	
	#adds a random floor tile for each coordinate in this range (the board without the border)
	for x in range(1, columns -1):
		for y in range(1, rows -1):
			#gridPositions.append(Vector2(x,y))
			floorTiles.set_cell(x, y, rand_range(0,7))
#			print(gridPositions[0]) this is how you get a specific index from an array


func genOuterWalls():
	randomize()
	
	#adds a random outer wall tile for each coordinate in that range (the borders of the board)
	for x in range(0, columns):
		for y in range(0, rows):
			if x == 0 or x == columns-1 or y == 0 or y == rows-1:
				#outerWallTiles.set_cell(x, y, rand_range(0,2)) THIS IS ONLY FOR TILES
				
				var outerWallInst											#creates a var to store the enemy instance		
				outerWallInst = outerWallScene.instance()
				var pos = Vector2(x,y)										#position is equal to the current X and Y values
				var posOnGrid = Vector2(pos.x*32, pos.y*32)					#converts from grid position to global position
				outerWallInst.set_pos(posOnGrid)
				outerWallInst.get_node("Sprite").set_frame(round(rand_range(1,2) + 24))
				add_child(outerWallInst)

func genUnits():
	
	#Goes through each coordinate in this range (the board without the border) and adds it to the gridPositions array
	#A unit can be a wall, food/soda, or an enemy
	for x in range(1, columns -1):
		#loops through both the X and Y axis
		for y in range(1, rows -1):
			#Doesn't add the (1,6) pos because that's the spawn nor the (6,1) pos because that's the exit
			if not (x == 1 and y == 6) and not (x == 6 and y == 1):
				#Doesn't add the (1,5) pos or the (2, 6) because those are right next to the spawn
				if not (x == 1 and y == 5) and not (x == 2 and y == 6):
					#Doesn't add the (5,1) or the (6, 2) pos because those are right next to the exit
					if not (x == 5 and y == 1) and not (x == 6 and y == 2):
						gridPositions.append(Vector2(x,y))

#This func is used to randomly generate the walls
func genWalls(x):
	#the X is a random num based on the difficulty
	var wallInst													#creates a var to store the enemy instance
	for wall in range(0, x):
		
		wallInst = wallScene.instance()
		var randomIndex = rand_range(0, gridPositions.size())		#the index of the pos from the gridPositions array
		var pos = gridPositions[randomIndex]						#sets the tile's pos to the random pos from the grid array
		gridPositions.remove(randomIndex)							#removes said array to prevent spawning two enemies in one tile
		var posOnGrid = Vector2(pos.x*32, pos.y*32)					#converts from grid position to global position
		wallInst.set_pos(posOnGrid)
		add_child(wallInst)
		
		#OUTDATED: NEEDS TO BE INSTANCE - wallTiles.set_cellv(pos, rand_range(0,7)) #set_cellv(Vector, ID) is used to add a tile to the game

#This func is used to randomly generate items based on the current difficulty
func genItems(x):
	#the X is a random num based on the difficulty
	var itemInst													#creates a var to store the item instance
	for item in range(0, x):
		
		#Chance for each type of enemy to show up
		var itemID = round(rand_range(1,4))
		
		#25% chance of the item being a weapon
		if itemID == 1:
			itemInst = weapon.instance()
		#75% chance of the item being food
		else:
			itemInst = food.instance()
			
		var randomIndex = rand_range(0, gridPositions.size())		#the index of the pos from the gridPositions array
		var pos = gridPositions[randomIndex]						#sets the enemy's pos to the random pos from the grid array
		gridPositions.remove(randomIndex)							#removes said array to prevent spawning two enemies in one tile
		var posOnGrid = Vector2(pos.x*32, pos.y*32)					#converts from grid position to global position
		itemInst.set_pos(posOnGrid)
		add_child(itemInst)
 
#This func is used to randomly generate enemies based on the current difficulty
func genEnemies(x):
	#the X is the difficulty log based on the current level
	var enemyInst													#creates a var to store the enemy instance
	for enemy in range(0, x):
		
		#50% chance for each type of enemy to show up
		var enemyID = round(rand_range(1,3))

		if enemyID == 1:
			enemyInst = enemy1.instance()
		elif enemyID == 2:
			enemyInst = enemy2.instance()
		else:
			enemyInst = enemy3.instance()
		
		var randomIndex = rand_range(0, gridPositions.size())		#the index of the pos from the gridPositions array
		var pos = gridPositions[randomIndex]						#sets the enemy's pos to the random pos from the grid array
		gridPositions.remove(randomIndex)							#removes said array to prevent spawning two enemies in one tile
		var posOnGrid = Vector2(pos.x*32, pos.y*32)					#converts from grid position to global position
		enemyInst.set_pos(posOnGrid)
		add_child(enemyInst)










