extends Node

## Main scene controller - bootstraps the game
## This is a simple wrapper that can be expanded for more complex initialization

func _ready():
	print("=== Modular Rhythm Game ===")
	print("Godot 4.6 Compatible")
	print("=========================")
	print("")
	print("Controls:")
	print("  WASD or Arrow Keys - Hit notes")
	print("  SPACE/Enter - Start game / Confirm")
	print("  ESC - Pause")
	print("")
	print("The game will auto-load with a test song.")
	print("To add custom songs, create SongData resources!")
