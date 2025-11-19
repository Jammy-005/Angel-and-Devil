class_name Angel extends Node2D

# Constants
const SIZE = 20
var POWER = Global.power
var ADJACENT = Global.adjacent
var FORCE_EUCLIDEAN = Global.force_euclidean

# Related objects
var tile : Tile
var camera : Camera2D

# Attributes
var tiles_in_range = []

#-------------------------------------------------------------------------------
#------------------------------ CORE FUNCTIONS ---------------------------------
#-------------------------------------------------------------------------------

# Constructor
func _ready():
	tile = get_parent().get_node("Tile")
	tile.host_angel()
	camera = get_node("Camera")
	position = tile.position
	
# Draw angel and mark redraw of underlying tiles
func _draw():
	tile.queue_redraw()
	
# Check target movement and move if possible
func move(target):
	if target in tiles_in_range and target.passable:
		tile.angel_leaves()
		tile = target
		tile.host_angel()
		position = tile.position
		camera.global_position = global_position
		return true
	else:
		return false

#-------------------------------------------------------------------------------
#---------------------------------- HELPERS ------------------------------------
#-------------------------------------------------------------------------------

# Get current tile that angel is on
func get_tile():
	return tile

# Check if angel dies
func is_dead():
	var dead = true
	for in_range in tiles_in_range:
		if in_range.passable and in_range != tile:
			dead = false
			break
	if dead:
		tile.kill()
	return dead
	
# Reset colours for tiles
func reset_colour():
	for in_range in tiles_in_range:
		in_range.reset_colour()

# Set colour for tiles in range
func set_colour_in_range():
	for in_range in tiles_in_range:
		in_range.set_colour_in_range()
		
# Get all tiles within power range, using BFS
func compute_tiles_in_range(dist, generate):
	if FORCE_EUCLIDEAN or ADJACENT == 2 or ADJACENT == 6:
		_compute_tiles_in_range(int(floor(dist)), generate)
	elif ADJACENT == 4:
		_compute_tiles_in_chessboard(dist, generate)
	elif ADJACENT == 3:
		_compute_tiles_in_triangle(int(floor(dist)), generate)

# Get all tiles within power range (Manhatten distance)
func _compute_tiles_in_range(dist, generate):
	tiles_in_range = []
	var queue = []
	tiles_in_range.append(tile)
	queue.append([tile, 0])
	while !queue.is_empty():
		var next_search = queue.pop_front()
		var current = next_search[0]
		var distance = next_search[1]
		if distance + 1 > dist:
			continue
		
		if generate:
			current.generate_neighbours()
		for neighbour in current.neighbours:
			if neighbour != null and neighbour not in tiles_in_range:
				tiles_in_range.append(neighbour)
				queue.append([neighbour, distance + 1])
	tiles_in_range.erase(tile)
	return tiles_in_range

# Get all tiles within power range (Chebyshev distance)
func _compute_tiles_in_chessboard(dist, generate):
	var even_gen = (dist - float(1)/2 == floor(dist))
	dist = floor(dist)
	
	tiles_in_range = []
	var queue = []
	
	tiles_in_range.append(tile)
	queue.append([tile, 1, 0, 0])
	while !queue.is_empty():
		var next_node = queue.pop_front()
		var current = next_node[0]
		var axis = next_node[1]
		var diff_x = next_node[2]
		var diff_y = next_node[3]
		
		for i in range(ADJACENT):
			var ndx = diff_x + axis * 1
			var ndy = diff_y + axis * 0
			if i == 1:
				ndx = diff_x + axis * 0
				ndy = diff_y + axis * 1
			elif i == 2:
				ndx = diff_x + axis * -1
				ndy = diff_y + axis * 0
			elif i == 3:
				ndx = diff_x + axis * 0
				ndy = diff_y + axis * -1
				
			if (
				(abs(ndx) <= dist and abs(ndy) <= dist)
				or (
					even_gen and generate
					and -ndx <= dist and ndx <= dist + 1
					and -ndy <= dist + 1 and ndy <= dist
				)
			):
				if current.neighbours[i] == null and generate:
					current.generate_neighbour(i)
				if current.neighbours[i] != null and current.neighbours[i] not in tiles_in_range:
					tiles_in_range.append(current.neighbours[i])
					queue.append([current.neighbours[i], -axis, ndx, ndy])
	tiles_in_range.erase(tile)
	return tiles_in_range
	
# Get all tiles within power range (triangle distance)
func _compute_tiles_in_triangle(dist, generate):
	tiles_in_range = []
	if dist == 0:
		return []
	if dist == 1:
		if generate:
			tile.generate_neighbours()
		tiles_in_range = tile.neighbours
		tiles_in_range.erase(tile)
		return tiles_in_range
	
	var queue = []
	@warning_ignore("integer_division")
	var start = dist / 2
	if dist % 2 == 1:
		start *= -1
	else:
		start -= 1
	
	tiles_in_range.append(tile)
	queue.append([tile, 1, start, start, start])
	while !queue.is_empty():
		var next_node = queue.pop_front()
		var current = next_node[0]
		var axis = next_node[1]
		var diff_x = next_node[2]
		var diff_y = next_node[3]
		var diff_z = next_node[4]
		
		for i in range(ADJACENT):
			var ndx = diff_x + axis * 1
			var ndy = diff_y + axis * 0
			var ndz = diff_z + axis * 0
			if i == 1:
				ndx = diff_x + axis * 0
				ndy = diff_y + axis * 1
				ndz = diff_z + axis * 0
			elif i == 2:
				ndx = diff_x + axis * 0
				ndy = diff_y + axis * 0
				ndz = diff_z + axis * 1
			if (
				(abs(ndx) < dist and abs(ndy) < dist and abs(ndz) < dist)
				or (
					dist == 2 and
					((abs(ndx) == dist and abs(ndy) == dist - 1 and abs(ndz) == dist - 1)
					or (abs(ndx) == dist - 1 and abs(ndy) == dist and abs(ndz) == dist - 1)
					or (abs(ndx) == dist - 1 and abs(ndy) == dist - 1 and abs(ndz) == dist))
				)
			):
				if current.neighbours[i] == null and generate:
					current.generate_neighbour(i)
				if current.neighbours[i] != null and current.neighbours[i] not in tiles_in_range:
					tiles_in_range.append(current.neighbours[i])
					queue.append([current.neighbours[i], -axis, ndx, ndy, ndz])
	tiles_in_range.erase(tile)
	return tiles_in_range
