class_name MainMenu
extends Control

## Main menu scene with navigation to game
## Demonstrates how to load and configure songs dynamically

@export var game_scene: PackedScene
@export var default_song: SongData  # Can be assigned in inspector

var button_hover_sound: AudioStreamPlayer

func _ready():
	# Create hover sound effect (optional polish)
	button_hover_sound = AudioStreamPlayer.new()
	add_child(button_hover_sound)
	
	# Setup button connections
	var play_button = $PlayButton
	play_button.pressed.connect(_on_play_pressed)
	play_button.mouse_entered.connect(_on_button_hover)
	
	print("Main Menu loaded - Click PLAY to start!")

func _on_button_hover():
	"""Optional: Play hover sound effect"""
	# Uncomment if you add a sound file
	# button_hover_sound.play()
	pass

func _on_play_pressed():
	"""Transition to game scene"""
	print("Starting game...")
	
	# Load the game scene
	if game_scene == null:
		game_scene = load("res://scenes/Game.tscn")
	
	var game_instance = game_scene.instantiate()
	
	# Optionally assign a specific song
	if default_song != null:
		game_instance.song_data = default_song
	
	# Replace current scene
	get_tree().root.add_child(game_instance)
	queue_free()

func _input(event):
	"""Allow Enter key to start game"""
	if event.is_action_pressed("accept"):
		_on_play_pressed()
