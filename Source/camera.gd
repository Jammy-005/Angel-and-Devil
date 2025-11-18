extends Camera2D

# Constants
const MOVE_SPEED = 1000 
const ZOOM_SPEED = 0.1
const MIN_ZOOM = 0.5
const MAX_ZOOM = 1.5
var POWER = Global.power

# Control schematic
const PAN_LEFT = "ui_left"
const PAN_RIGHT = "ui_right"
const PAN_UP = "ui_up"
const PAN_DOWN = "ui_down"
const ZOOM_IN = "Zoom In"
const ZOOM_OUT = "Zoom Out"
const RETURN_TO_ANGEL = "ui_accept"

# Related object
var game : Game
var angel : Angel

#-------------------------------------------------------------------------------
#------------------------------ CORE FUNCTIONS ---------------------------------
#-------------------------------------------------------------------------------

# Constructor
func _ready():
	game = get_parent().get_parent()
	angel = get_parent()

# Process keyboard inputs (pan, zoom, return to angel)
func _process(delta):
	var input_vector = Vector2.ZERO
	
	var change = false
	if Input.is_action_pressed(PAN_RIGHT):
		input_vector.x += 1
		change = true
	if Input.is_action_pressed(PAN_LEFT):
		input_vector.x -= 1
		change = true
	if Input.is_action_pressed(PAN_DOWN):
		input_vector.y += 1
		change = true
	if Input.is_action_pressed(PAN_UP):
		input_vector.y -= 1
		change = true
	if Input.is_action_pressed(ZOOM_IN):
		zoom += Vector2(ZOOM_SPEED, ZOOM_SPEED)
		change = true
	if Input.is_action_pressed(ZOOM_OUT):
		zoom -= Vector2(ZOOM_SPEED, ZOOM_SPEED)
		change = true
	if Input.is_action_just_pressed(RETURN_TO_ANGEL):
		global_position = angel.global_position
		change = true
	
	if change:
		input_vector = input_vector.normalized()
		zoom.x = clamp(zoom.x, MIN_ZOOM, MAX_ZOOM)
		zoom.y = clamp(zoom.x, MIN_ZOOM, MAX_ZOOM)
		position += input_vector * MOVE_SPEED * delta
		game.reset_drawn()
		update_map()

#-------------------------------------------------------------------------------
#---------------------------------- HELPERS ------------------------------------
#-------------------------------------------------------------------------------

# Check if current position is on screen
func onscreen(pos):
	var extra = 2 * Global.radius
	var camera_size = get_viewport().get_visible_rect().size + Vector2(extra, extra)
	camera_size /= zoom
	var camera_pos = get_screen_center_position()
	var screen_rect = Rect2(camera_pos - camera_size / 2, camera_size)
	return screen_rect.has_point(pos)

# Update the map after camera has changed positions
func update_map():
	for pos in game.get_tiles():
		if onscreen(pos):
			var tile = game.get_tile(pos)
			tile.queue_redraw()
			return
	
