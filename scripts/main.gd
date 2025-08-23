extends Area2D

var tiles = []
var solved = []
var mouse = false

func _ready():
	start_game()

func start_game():
	tiles = [$Tile1, $Tile2, $Tile3, $Tile4, $Tile5, $Tile6, $Tile7, $Tile8, $Tile9, $Tile10, $Tile11, $Tile12, $Tile13, $Tile14, $Tile15, $Tile16 ]
	solved = tiles.duplicate()
	shuffle_tiles()
	
func shuffle_tiles():
	var previous = 73
	var previous_1 = 73
	for t in range(302,365):
		var tile = randi() % 8
		if tiles[tile] != $Tile16 and tile != previous and tile != previous_1:
			var rows = int(tiles[tile].position.y / 73)
			var cols = int(tiles[tile].position.x / 73)
			check_neighbours(rows,cols)
			previous_1 = previous
			previous = tile
			
func _input(event):
	if event is InputEventMouseButton:
		var rows = int(event.position.y / 73)
		var cols = int(event.position.x / 73)
		check_neighbours(rows, cols)

func check_neighbours(rows, cols):
	var empty = false
	var done = false
	var pos = rows * 4 + cols
	while !empty and !done:
		var new_pos = tiles[pos].position
		if rows < 4:
			new_pos.y += 73
			empty = find_empty(new_pos,pos)
			new_pos.y -= 73
		if rows > 0:
			new_pos.y -= 73
			empty = find_empty(new_pos,pos)
			new_pos.y += 73
		if cols < 4:
			new_pos.x += 73
			empty = find_empty(new_pos,pos)
			new_pos.x -= 73
		if cols > 0:
			new_pos.x -= 73
			empty = find_empty(new_pos,pos)
			new_pos.x += 73
		done = true
			
func find_empty(position,pos):
	var new_rows = int(position.y / 73)
	var new_cols = int(position.x / 73)
	var new_pos = new_rows * 3 + new_cols
	if tiles[new_pos] == $Tile16:
		swap_tiles(new_pos, pos)
		return true
	else:
		return false
		
func swap_tiles(tile_src, tile_dst):
	var temp_pos = tiles[tile_src].position
	tiles[tile_src].position = tiles[tile_dst].position
	tiles[tile_dst].position = temp_pos
	var temp_tile = tiles[tile_src]
	tiles[tile_src] = tiles[tile_dst]
	tiles[tile_dst] = temp_tile
	
	

	
