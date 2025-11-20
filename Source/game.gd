class_name Game extends Node2D

# Constants
var ADJACENT = Global.adjacent
var TOLERANCE = 1^(-10 * ADJACENT)
var POWER = Global.power
var SIZE = Global.size
var GENERATE = (SIZE == 0)

# Related object
var angel : Angel

# Attributes
var angel_turn = false
var tiles : Dictionary
var devil : Tile = null
var drawn : Array[Tile] = []

#-------------------------------------------------------------------------------
#------------------------------ CORE FUNCTIONS ---------------------------------
#-------------------------------------------------------------------------------

# Constructor
func _ready():
	angel = get_node("Angel")
	# Pregenerate finite board if applicable
	angel.compute_tiles_in_range(float(SIZE - 1) / 2, true)

# Turn management
func turn(target):
	if (
		(angel_turn and angel.move(target))
		or (!angel_turn and angel.get_tile() != target and target.remove())
	):
		angel_turn = !angel_turn
		await get_tree().process_frame
		
		if !angel_turn:
			angel.reset_colour()
			angel.compute_tiles_in_range(POWER, GENERATE)
			for tile in tiles:
				print(tiles[tile].neighbours)
		else:
			if devil != null:
				devil.remove_devil()
			devil = target
			devil.set_devil()
			angel.compute_tiles_in_range(POWER, GENERATE)
			angel.set_colour_in_range()
		
		angel.is_dead()
		angel.tile.set_colour_in_range()
		reset_drawn()
		angel.queue_redraw()

# Restart game
func _process(_delta):
	if Input.is_key_pressed(KEY_R):
		get_tree().change_scene_to_file("res://title_screen.tscn")

#-------------------------------------------------------------------------------
#---------------------------------- HELPERS ------------------------------------
#-------------------------------------------------------------------------------

# Add tile to list of drawn tiles in current frame
func add_drawn(tile):
	drawn.append(tile)
	
# Check if tile has been drawn in current frame
func is_drawn(tile):
	return drawn.has(tile)

# Resets the drawn state
func reset_drawn():
	drawn = []

# Align global coordinates to nearest integer
func align(pos):
	return pos.snapped(Vector2(TOLERANCE, TOLERANCE))

# Add tile to list of existing tiles
func add_tile(tile):
	tiles[align(tile.global_position)] = tile

# Check if there exists a tile at given global coordintes
func has_tile(pos):
	return tiles.has(align(pos))

# Return tile at given global coordinates
func get_tile(pos):
	return tiles[align(pos)]
	
# Return all tiles
func get_tiles():
	return tiles
