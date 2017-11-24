extends TileMap

var tileSize = 32
var halfTileSize = 16

var gridSize = Vector2(8, 8)
var grid = []


func _ready():
	for x in range(gridSize.x):
		grid.append([])
		for x in range(gridSize.y):
			grid[x].append(null)

func isCellVacant():
	pass

func updateChildPos(child, newPos, direction):
	pass