extends Node2D

const GRID_SIZE = 4
const TILE_SPACING = 73.0 
const GRID_OFFSET = Vector2(46, 103)
const SHUFFLE_MOVES = 100

@onready var success_message_label = $SuccessMessageLabel
@onready var click_sound = $Click
@onready var win_sound = $WinSound
@onready var gridlayout: Sprite2D = $Gridlayout

var tiles = []
var solved_state = []
var empty_tile_node 
var game_over = false
var move_count = 0  

signal puzzle_solved(moves: int)

@export var force_win: bool = true # win 

func _ready():
	initialize_tiles()
	start_game()

func _process(delta: float) -> void:
	if force_win and not game_over:
		handle_victory()

func initialize_tiles():
	if tiles.is_empty():
		for i in range(1, (GRID_SIZE * GRID_SIZE) + 1):
			var tile_node = get_node("Tile" + str(i))
			if tile_node == null:
				push_error("Tile" + str(i) + " not found!")
				return
			tiles.append(tile_node)
		
		empty_tile_node = get_node("Tile16")
		if empty_tile_node == null:
			push_error("Empty tile (Tile16) not found!")
			return
		
		solved_state = tiles.duplicate()


# Si résolu alors commence une nouvelle partie
func start_game():
	$Complete_animation/AnimatedSprite2D.hide()
	gridlayout.show()
	game_over = false
	move_count = 0
	reset_tiles_to_solved_state()
	shuffle_tiles(SHUFFLE_MOVES)

func reset_tiles_to_solved_state():
	for i in tiles.size():
		tiles[i] = solved_state[i]
		tiles[i].position = solved_state[i].position

func shuffle_tiles(moves_count: int):
	var empty_pos = get_tile_grid_pos(empty_tile_node)
	var last_move = Vector2i(-1, -1)
	for i in range(moves_count):
		var valid_moves = get_valid_moves(empty_pos)
		if valid_moves.size() > 1:
			valid_moves.erase(last_move)
		if valid_moves.is_empty():
			continue
		var target_pos = valid_moves.pick_random()
		var empty_index = get_index_from_grid_pos(empty_pos)
		var target_index = get_index_from_grid_pos(target_pos)
		swap_tiles(empty_index, target_index)
		last_move = empty_pos
		empty_pos = target_pos

func get_valid_moves(pos: Vector2i) -> Array[Vector2i]:
	var valid_moves: Array[Vector2i] = []
	if pos.y > 0: 
		valid_moves.append(Vector2i(pos.x, pos.y - 1))
	if pos.y < GRID_SIZE - 1: 
		valid_moves.append(Vector2i(pos.x, pos.y + 1))
	if pos.x > 0: 
		valid_moves.append(Vector2i(pos.x - 1, pos.y))
	if pos.x < GRID_SIZE - 1: 
		valid_moves.append(Vector2i(pos.x + 1, pos.y))
	return valid_moves

func _input(event):
	if game_over:
		if event is InputEventMouseButton and event.pressed:
			start_game()
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		handle_mouse_click(event.position)
	elif event.is_action_pressed("ui_accept"):
		start_game()

func handle_mouse_click(mouse_pos: Vector2):
	var grid_pos = screen_to_grid_pos(mouse_pos)
	if is_valid_grid_position(grid_pos):
		try_move_tile(grid_pos.y, grid_pos.x)

func screen_to_grid_pos(screen_pos: Vector2) -> Vector2i:
	var relative_pos = screen_pos - GRID_OFFSET
	var clicked_col = int((relative_pos.x + TILE_SPACING / 2) / TILE_SPACING)
	var clicked_row = int((relative_pos.y + TILE_SPACING / 2) / TILE_SPACING)
	return Vector2i(clicked_col, clicked_row)

func is_valid_grid_position(grid_pos: Vector2i) -> bool:
	return (grid_pos.x >= 0 and grid_pos.x < GRID_SIZE and 
			grid_pos.y >= 0 and grid_pos.y < GRID_SIZE)

func try_move_tile(row: int, col: int):
	var clicked_index = get_index_from_grid_pos(Vector2i(col, row))
	var clicked_tile = tiles[clicked_index]
	if clicked_tile == empty_tile_node:
		return
	var move_made = false
	var empty_pos = get_tile_grid_pos(empty_tile_node)
	var clicked_pos = Vector2i(col, row)
	var distance = abs(empty_pos.x - clicked_pos.x) + abs(empty_pos.y - clicked_pos.y)
	if distance == 1:
		var empty_index = get_index_from_grid_pos(empty_pos)
		swap_tiles(clicked_index, empty_index)
		move_made = true
	if move_made:
		move_count += 1
		play_click_sound()
		if check_if_solved():
			handle_victory()

func play_click_sound():
	if click_sound != null:
		click_sound.play()

# VICTOIRE !!!
func handle_victory():
	game_over = true
	$Complete_animation/AnimatedSprite2D.show()
	gridlayout.hide()
	if win_sound != null:
		win_sound.play()
	puzzle_solved.emit(move_count)
	$Complete_animation/AnimatedSprite2D.play("complete")

func check_if_solved() -> bool:
	return tiles == solved_state

func swap_tiles(index_a: int, index_b: int):
	var temp_pos = tiles[index_a].position
	tiles[index_a].position = tiles[index_b].position
	tiles[index_b].position = temp_pos
	var temp_tile = tiles[index_a]
	tiles[index_a] = tiles[index_b]
	tiles[index_b] = temp_tile

func get_index_from_grid_pos(grid_pos: Vector2i) -> int:
	return grid_pos.y * GRID_SIZE + grid_pos.x

func get_tile_grid_pos(tile_node) -> Vector2i:
	var relative_pos = tile_node.position - GRID_OFFSET
	var col = int((relative_pos.x + TILE_SPACING / 2) / TILE_SPACING)
	var row = int((relative_pos.y + TILE_SPACING / 2) / TILE_SPACING)
	return Vector2i(col, row)

func get_move_count() -> int:
	return move_count

func is_game_over() -> bool:
	return game_over

func get_completion_percentage() -> float:
	var correct_tiles = 0
	for i in tiles.size():
		if tiles[i] == solved_state[i]:
			correct_tiles += 1
	return float(correct_tiles) / float(tiles.size()) * 100.0


func _on_button_pressed() -> void:
	click_sound.play(0)
	
	
