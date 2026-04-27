class_name Note
extends Sprite2D

## Visual representation of a note that scrolls toward the target
## Handles movement, hit detection, and visual feedback

signal note_hit(note: Note)
signal note_missed(note: Note)

# Lane configuration - matches input actions
const LANE_NAMES = ["left", "down", "up", "right"]
const LANE_COLORS = [
	Color(0.8, 0.2, 0.2),  # Left - Red
	Color(0.2, 0.2, 0.8),  # Down - Blue
	Color(0.2, 0.8, 0.2),  # Up - Green
	Color(0.8, 0.8, 0.2),  # Right - Yellow
]

@export var lane: int = 0
@export var hit_time: float = 0.0  # When this note should be hit (in song time)
@export var is_sustain: bool = false
@export var sustain_duration: float = 0.0

var scroll_speed: float = 5.0  # Units per second
var target_y: float = 100.0    # Y position where notes should be hit
var is_hit: bool = false
var spawn_time: float = 0.0

# Visual components
var color_rect: ColorRect
var label: Label

func _ready():
	# Create visual representation
	color_rect = ColorRect.new()
	color_rect.color = LANE_COLORS[lane]
	color_rect.size = Vector2(50, 50)
	color_rect.position = Vector2(-25, -25)
	add_child(color_rect)
	
	# Optional: Add direction indicator
	label = Label.new()
	label.text = ">" if lane == 3 else "<" if lane == 0 else "^" if lane == 2 else "v"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size = Vector2(50, 50)
	label.position = Vector2(-25, -25)
	label.add_theme_color_override("font_color", Color.WHITE)
	add_child(label)

func _process(delta):
	if not is_hit:
		# Move note toward target
		position.y += scroll_speed * delta
		
		# Check if note has passed the target (missed)
		if position.y > target_y + 60 and not is_hit:
			note_missed.emit(self)

func set_position_from_time(current_song_time: float, spawn_offset: float):
	"""
	Calculate Y position based on timing.
	Notes spawn above screen and move down to hit position.
	"""
	var time_until_hit = hit_time - current_song_time
	var distance_from_target = time_until_hit * scroll_speed * 100  # Scale for visibility
	position.y = target_y - distance_from_target
	position.x = get_lane_x(lane)

func get_lane_x(lane_index: int) -> float:
	"""Get X position for each lane (4 lanes centered on screen)"""
	var lane_width = 60.0
	var start_x = 640 - (lane_width * 2)  # Center minus half total width
	return start_x + (lane_index * lane_width) + (lane_width / 2)

func check_hit(input_time: float, hit_window: float = 0.15) -> String:
	"""
	Check if input timing matches this note.
	Returns rating: "SICK", "GOOD", "BAD", or "MISS"
	"""
	if is_hit:
		return "MISS"
	
	var time_diff = abs(input_time - hit_time)
	
	if time_diff <= hit_window * 0.25:
		return "SICK"
	elif time_diff <= hit_window * 0.5:
		return "GOOD"
	elif time_diff <= hit_window:
		return "BAD"
	else:
		return "MISS"

func mark_as_hit(rating: String):
	"""Visual feedback when note is hit"""
	is_hit = true
	
	match rating:
		"SICK":
			color_rect.color = Color.WHITE
			scale = Vector2(1.3, 1.3)
		"GOOD":
			color_rect.color = Color(0.8, 0.8, 0.8)
		"BAD":
			color_rect.color = Color(0.5, 0.5, 0.5)
	
	# Shrink animation
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.1)
	tween.tween_callback(queue_free)

func mark_as_missed():
	"""Visual feedback when note is missed"""
	is_hit = true
	color_rect.color = Color.DARK_RED
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_callback(queue_free)
