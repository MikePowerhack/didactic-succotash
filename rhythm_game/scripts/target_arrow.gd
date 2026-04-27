class_name TargetArrow
extends ColorRect

## Static target arrows that indicate where to hit notes
## Provides visual feedback when player presses input

const LANE_COLORS = [
	Color(0.8, 0.2, 0.2),  # Left - Red
	Color(0.2, 0.2, 0.8),  # Down - Blue
	Color(0.2, 0.8, 0.2),  # Up - Green
	Color(0.8, 0.8, 0.2),  # Right - Yellow
]

@export var lane: int = 0

var base_color: Color
var is_pressed: bool = false

func _ready():
	color = LANE_COLORS[lane]
	base_color = color
	size = Vector2(50, 50)
	position = Vector2(get_lane_x(lane) - 25, 100 - 25)
	
	# Add direction indicator
	var label = Label.new()
	label.text = ">" if lane == 3 else "<" if lane == 0 else "^" if lane == 2 else "v"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size = Vector2(50, 50)
	label.position = Vector2(0, 0)
	label.add_theme_color_override("font_color", Color.WHITE)
	add_child(label)

func get_lane_x(lane_index: int) -> float:
	"""Get X position for each lane (4 lanes centered on screen)"""
	var lane_width = 60.0
	var start_x = 640 - (lane_width * 2)
	return start_x + (lane_index * lane_width) + (lane_width / 2)

func press():
	"""Visual feedback when lane is pressed"""
	is_pressed = true
	color = Color.WHITE * 1.5
	scale = Vector2(1.2, 1.2)
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)
	tween.tween_callback(func(): 
		if not is_pressed:
			color = base_color
	)

func release():
	"""Reset visual state when lane is released"""
	is_pressed = false
	var tween = create_tween()
	tween.tween_property(self, "color", base_color, 0.1)

func flash_hit(rating: String):
	"""Flash effect when note is successfully hit"""
	match rating:
		"SICK":
			color = Color.WHITE
		"GOOD":
			color = Color(0.8, 0.8, 0.8)
		"BAD":
			color = Color(0.5, 0.5, 0.5)
	
	var tween = create_tween()
	tween.tween_property(self, "color", base_color, 0.15)
