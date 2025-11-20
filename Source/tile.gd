class_name Tile extends Node2D

# Constants
const PASSABLE = Color(0.808, 0.725, 0.549, 1.0)
const NOT_PASSABLE = Color(0.0, 0.0, 0.0, 1.0)
const IN_RANGE = Color(0.588, 0.745, 0.698, 1.0)
const BORDER = Color(0.922, 0.871, 0.769, 1.0)
const BORDER_WIDTH = 5
var ADJACENT = Global.adjacent
var RADIUS = Global.radius
var LOCK = (Global.size != 0)

# Related objects
var game : Game
var camera : Camera2D
var area : Area2D
var sprite : Sprite2D
var neighbours : Array[Tile] = []

# Attributes
var passable = true
var colour = PASSABLE
var axis = PI / 2
var shape : Polygon2D
var clipper : Polygon2D
var edge_distance : float

#-------------------------------------------------------------------------------
#------------------------------ CORE FUNCTIONS ---------------------------------
#-------------------------------------------------------------------------------

# Constructor when object created
func _init():
	neighbours.resize(ADJACENT)

# Constructor when adding to scene
func _ready():
	game = get_parent()
	camera = get_parent().get_node("Angel/Camera")
	area = Area2D.new()
	edge_distance = compute_edge_distance()
	shape = make_shape(edge_distance)
	clipper = make_shape(edge_distance - BORDER_WIDTH)
	add_child(clipper)
	clipper.clip_children = CanvasItem.CLIP_CHILDREN_ONLY
	make_collider()
	game.add_tile(self)

# Make the game take a turn with this clicked tile as the target
func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		game.turn(self)

# Draw and lazy generate
func _draw():
	if not camera.onscreen(global_position):
		return
	
	draw_colored_polygon(shape.polygon, colour)
	game.add_drawn(self)
	
	# Generate neighbours (locked if size != 0)
	if not LOCK:
		generate_neighbours()
	
	# Draw neighbours if they're onscreen
	for i in range(ADJACENT):
		# Draw neighbours
		if neighbours[i] != null and not game.is_drawn(neighbours[i]):
			neighbours[i].queue_redraw()
			
	draw_polyline(shape.polygon, BORDER, BORDER_WIDTH)

#-------------------------------------------------------------------------------
#---------------------------------- HELPERS ------------------------------------
#-------------------------------------------------------------------------------

# Kill the angel
func kill():
	sprite.texture = load("res://tombstone.png")
	sprite.scale = Vector2(0.095, 0.059)

# Host angel at tile
func host_angel():
	sprite = Sprite2D.new()
	sprite.texture = load("res://angel.png")
	sprite.scale = Vector2(0.145, 0.145)
	clipper.add_child(sprite)
	set_colour_in_range()

# Angel departs tile
func angel_leaves():
	sprite.queue_free()
	reset_colour()

# Move devil onto tile
func set_devil():
	sprite = Sprite2D.new()
	sprite.texture = load("res://devil.jpg")
	sprite.scale = Vector2(0.455, 0.405)
	clipper.add_child(sprite)

# Remove devil from tile
func remove_devil():
	sprite.queue_free()

# Generate neighbours
func generate_neighbours():
	for i in range(ADJACENT):
		if neighbours[i] == null:
			generate_neighbour(i)

# Link current node to all neighbours
func link_neighbours():
	for i in range(ADJACENT):
		link_neighbour(i)

# Link current node to given neighbour
func link_neighbour(i):
	var neighbour_position = global_position + get_neighbour_position(i)
	if neighbours[i] == null and game.has_tile(neighbour_position):
		neighbours[i] = game.get_tile(neighbour_position)
		return true
	else:
		return false
		
# Generate neighbour at particular index
func generate_neighbour(i):
	if neighbours[i] == null and not link_neighbour(i):
		var neighbour = Tile.new()
		neighbours[i] = neighbour
		neighbour.position = position + get_neighbour_position(i)
		neighbour.axis = axis + PI
		get_parent().add_child(neighbour)

# Compute edge distance of shape under use
func compute_edge_distance():
	var vertices = ADJACENT
	# Add width if 1 dimensional
	if vertices == 2:
		vertices = 4
	return RADIUS / (2 * cos(PI / vertices))

# Make the tile's shape
func make_shape(distance):
	var points = []
	var offset = PI / ADJACENT
	var vertices = ADJACENT
	
	# Add width if 1 dimensional
	if vertices == 2:
		vertices = 4
		offset = PI / 4
		axis = 0
		
	var angles = Global.get_axises(vertices)
	for i in range(vertices):
		points.append(to_vector(distance, offset + axis + angles[i]))
	points.append(to_vector(distance, offset + axis + angles[0]))
	
	var polygon = Polygon2D.new()
	polygon.polygon = points
	return polygon

# Make tile interactable (ie. clickable, movable)
func make_collider():
	add_child(area)
	var collider = CollisionPolygon2D.new()
	collider.polygon = shape.polygon
	area.add_child(collider)
	area.connect("input_event", _input_event)

# Remove this tile if not already removed, returning success of removal
func remove():
	if passable:
		passable = false
		colour = NOT_PASSABLE
		queue_redraw()
		return true
	else:
		return false

# Set colour to be in range
func set_colour_in_range():
	if passable:
		colour = IN_RANGE

# Reset colour to PASSABLE
func reset_colour():
	if passable:
		colour = PASSABLE

# Get coordinate of neighbour given its index
func get_neighbour_position(index):
	return to_vector(RADIUS, Global.axises[index] + axis)

# Convert polar coordinates to a vector
func to_vector(radius, angle):
	return Vector2(radius * cos(angle), radius * sin(angle))
	
# Confirm if this tile has the given neighbour
func has_neighbour(neighbour):
	return neighbours.has(neighbour)

# Print tile info
func info():
	print("Tile - position: ", position, " - passable: ", passable)
	var neighbouring = []
	for neighbour in neighbours:
		neighbouring.append(neighbour.global_position)
	print("Neighbours: ", neighbouring)
