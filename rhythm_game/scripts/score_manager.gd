class_name ScoreManager
extends Node

## Manages scoring, combo, and game statistics
## Modular design allows easy customization of scoring systems

signal score_changed(new_score: int)
signal combo_changed(new_combo: int)
signal health_changed(new_health: float)
signal rating_display(rating: String)

# Scoring configuration - easily adjustable for difficulty balancing
const SCORE_SICK = 350
const SCORE_GOOD = 200
const SCORE_BAD = 100
const SCORE_MISS = 0

const HEALTH_SICK = 0.15
const HEALTH_GOOD = 0.08
const HEALTH_BAD = -0.05
const HEALTH_MISS = -0.15

var score: int = 0
var combo: int = 0
var max_combo: int = 0
var health: float = 0.5  # 0.0 to 1.0
var total_notes: int = 0
var notes_hit: int = 0

# Hit statistics
var sick_count: int = 0
var good_count: int = 0
var bad_count: int = 0
var miss_count: int = 0

func _ready():
	reset()

func reset():
	"""Reset all scores for a new song"""
	score = 0
	combo = 0
	max_combo = 0
	health = 0.5
	total_notes = 0
	notes_hit = 0
	sick_count = 0
	good_count = 0
	bad_count = 0
	miss_count = 0
	emit_signals()

func set_total_notes(count: int):
	"""Set total note count for accuracy calculation"""
	total_notes = count

func register_hit(rating: String):
	"""Register a successful hit with rating"""
	match rating:
		"SICK":
			score += SCORE_SICK + (combo * 10)  # Combo bonus
			health = clampf(health + HEALTH_SICK, 0.0, 1.0)
			sick_count += 1
		"GOOD":
			score += SCORE_GOOD + (combo * 5)
			health = clampf(health + HEALTH_GOOD, 0.0, 1.0)
			good_count += 1
		"BAD":
			score += SCORE_BAD
			health = clampf(health + HEALTH_BAD, 0.0, 1.0)
			bad_count += 1
	
	if rating != "MISS":
		combo += 1
		notes_hit += 1
		if combo > max_combo:
			max_combo = combo
	
	rating_display.emit(rating)
	emit_signals()

func register_miss():
	"""Register a missed note"""
	combo = 0
	health = clampf(health + HEALTH_MISS, 0.0, 1.0)
	miss_count += 1
	rating_display.emit("MISS")
	emit_signals()

func emit_signals():
	"""Emit all update signals"""
	score_changed.emit(score)
	combo_changed.emit(combo)
	health_changed.emit(health)

func get_accuracy() -> float:
	"""Calculate hit accuracy percentage"""
	if total_notes == 0:
		return 0.0
	return (float(notes_hit) / float(total_notes)) * 100.0

func get_letter_grade() -> String:
	"""Get letter grade based on accuracy"""
	var accuracy = get_accuracy()
	if accuracy >= 95.0:
		return "S"
	elif accuracy >= 90.0:
		return "A"
	elif accuracy >= 80.0:
		return "B"
	elif accuracy >= 70.0:
		return "C"
	elif accuracy >= 60.0:
		return "D"
	else:
		return "F"

func is_game_over() -> bool:
	"""Check if player has failed (health depleted)"""
	return health <= 0.0

func is_song_complete() -> bool:
	"""Check if song is completed successfully"""
	return health > 0.0 and notes_hit + miss_count >= total_notes
