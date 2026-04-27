class_name GameScene
extends Node2D

## Main game scene that orchestrates all gameplay elements
## Handles note spawning, input detection, timing synchronization, and game state

@export var song_data: SongData  # Assign in inspector or via code
@export var score_manager: ScoreManager

# Scene nodes (will be created programmatically if not present)
var note_container: Node2D
var target_container: Node2D
var ui_container: CanvasLayer
var audio_player: AudioStreamPlayer

# Timing and gameplay variables
var song_start_time: float = 0.0
var current_song_time: float = 0.0
var is_playing: bool = false
var is_paused: bool = false

# Note management
var active_notes: Array[Note] = []
var spawned_note_times: Array[float] = []  # Track which notes have been spawned

# Configuration
const SPAWN_OFFSET_SECONDS: float = 3.0  # How early notes spawn before hit time
const HIT_WINDOW: float = 0.15  # Base hit window in seconds
const DESPAWN_OFFSET_SECONDS: float = 1.0  # How late to keep notes before despawning

# UI Elements
var score_label: Label
var combo_label: Label
var health_bar: ProgressBar
var song_info_label: Label
var rating_label: Label
var pause_menu: Panel

func _ready():
	# Auto-create required nodes if this is run standalone
	setup_scene()
	
	if song_data == null:
		push_warning("No song data assigned! Loading test song.")
		load_test_song()
	
	if score_manager == null:
		score_manager = ScoreManager.new()
		add_child(score_manager)
	
	# Connect signals
	score_manager.score_changed.connect(_on_score_changed)
	score_manager.combo_changed.connect(_on_combo_changed)
	score_manager.health_changed.connect(_on_health_changed)
	score_manager.rating_display.connect(_on_rating_display)
	
	setup_targets()
	setup_ui()
	
	print("Game ready! Press SPACE to start")

func setup_scene():
	"""Create required scene structure if not present"""
	# Create audio player
	if not has_node("AudioPlayer"):
		audio_player = AudioStreamPlayer.new()
		audio_player.name = "AudioPlayer"
		add_child(audio_player)
	
	# Create containers
	if not has_node("NoteContainer"):
		note_container = Node2D.new()
		note_container.name = "NoteContainer"
		add_child(note_container)
	
	if not has_node("TargetContainer"):
		target_container = Node2D.new()
		target_container.name = "TargetContainer"
		add_child(target_container)
	
	if not has_node("UI"):
		ui_container = CanvasLayer.new()
		ui_container.name = "UI"
		add_child(ui_container)

func load_test_song():
	"""Create a simple test song for immediate playability"""
	song_data = SongData.new()
	song_data.song_name = "Test Song"
	song_data.artist = "Dev Team"
	song_data.bpm = 120.0
	song_data.scroll_speed = 4.0
	
	# Generate test notes (simple pattern)
	var beat_duration = 60.0 / song_data.bpm
	for i in range(0, 60):  # 60 beats
		var time = i * beat_duration
		if i > 4:  # Start after intro
			var lane = i % 4
			var note = NoteData.new()
			note.time = time
			note.lane = lane
			song_data.notes.append(note)
	
	print("Test song loaded with ", song_data.notes.size(), " notes")

func setup_targets():
	"""Create target arrows for each lane"""
	for i in range(4):
		var target = TargetArrow.new()
		target.lane = i
		target_container.add_child(target)

func setup_ui():
	"""Create UI elements"""
	# Score label
	score_label = Label.new()
	score_label.text = "Score: 0"
	score_label.position = Vector2(20, 20)
	score_label.add_theme_font_size_override("font_size", 24)
	ui_container.add_child(score_label)
	
	# Combo label
	combo_label = Label.new()
	combo_label.text = ""
	combo_label.position = Vector2(20, 60)
	combo_label.add_theme_font_size_override("font_size", 28)
	ui_container.add_child(combo_label)
	
	# Health bar
	health_bar = ProgressBar.new()
	health_bar.position = Vector2(20, 100)
	health_bar.size = Vector2(200, 20)
	health_bar.value = 50
	health_bar.max_value = 100
	ui_container.add_child(health_bar)
	
	# Song info
	song_info_label = Label.new()
	song_info_label.text = "Press SPACE to start"
	song_info_label.position = Vector2(640, 50)
	song_info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	song_info_label.add_theme_font_size_override("font_size", 32)
	ui_container.add_child(song_info_label)
	
	# Rating display (center screen)
	rating_label = Label.new()
	rating_label.text = ""
	rating_label.position = Vector2(640, 300)
	rating_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rating_label.add_theme_font_size_override("font_size", 48)
	rating_label.anchor_left = 0.5
	rating_label.anchor_right = 0.5
	ui_container.add_child(rating_label)
	
	# Pause menu (hidden by default)
	pause_menu = Panel.new()
	pause_menu.position = Vector2(440, 260)
	pause_menu.size = Vector2(400, 200)
	pause_menu.visible = false
	var pause_label = Label.new()
	pause_label.text = "PAUSED\nPress ESC to resume"
	pause_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pause_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	pause_menu.add_child(pause_label)
	ui_container.add_child(pause_menu)

func _input(event):
	if event.is_action_pressed("accept") and not is_playing:
		start_song()
	elif event.is_action_pressed("ui_cancel") and is_playing:
		toggle_pause()
	
	# Handle note hits when playing
	if is_playing and not is_paused:
		handle_input(event)

func handle_input(event):
	"""Process input for hitting notes"""
	if event is InputEventKey and event.pressed:
		for lane_idx in range(4):
			var action_name = ["left", "down", "up", "right"][lane_idx]
			if event.is_action(action_name):
				hit_note(lane_idx)
				# Visual feedback on target
				var targets = target_container.get_children()
				if lane_idx < targets.size():
					targets[lane_idx].press()

func _unhandled_input(event):
	"""Handle key releases for target visual feedback"""
	if event is InputEventKey and not event.pressed:
		for lane_idx in range(4):
			var action_name = ["left", "down", "up", "right"][lane_idx]
			if event.is_action(action_name):
				var targets = target_container.get_children()
				if lane_idx < targets.size():
					targets[lane_idx].release()

func start_song():
	"""Begin the song and gameplay"""
	if song_data == null or song_data.audio_stream == null:
		print("No audio stream! Starting without music.")
	else:
		audio_player.stream = song_data.audio_stream
		audio_player.play()
	
	song_start_time = Time.get_ticks_msec() / 1000.0
	current_song_time = 0.0
	is_playing = true
	is_paused = false
	
	score_manager.reset()
	score_manager.set_total_notes(song_data.notes.size())
	
	song_info_label.text = "%s - %s" % [song_data.song_name, song_data.artist]
	
	print("Song started!")

func toggle_pause():
	"""Pause/unpause the game"""
	is_paused = !is_paused
	pause_menu.visible = is_paused
	get_tree().paused = is_paused
	
	if is_paused:
		audio_player.stream_paused = true
	else:
		audio_player.stream_paused = false
		# Adjust start time to account for pause duration
		song_start_time = Time.get_ticks_msec() / 1000.0 - current_song_time

func _process(delta):
	if not is_playing or is_paused:
		return
	
	# Update song timing
	current_song_time = Time.get_ticks_msec() / 1000.0 - song_start_time
	
	# Spawn notes that are coming up
	spawn_notes()
	
	# Update active notes
	update_notes(delta)
	
	# Check win/lose conditions
	check_game_state()

func spawn_notes():
	"""Spawn notes that are within the spawn window"""
	var sorted_notes = song_data.get_sorted_notes()
	
	for note_data in sorted_notes:
		# Skip if already spawned
		if note_data.time in spawned_note_times:
			continue
		
		# Spawn if within spawn window
		var time_until_hit = note_data.time - current_song_time
		if time_until_hit <= SPAWN_OFFSET_SECONDS and time_until_hit >= -DESPAWN_OFFSET_SECONDS:
			spawn_note(note_data)
			spawned_note_times.append(note_data.time)

func spawn_note(note_data: NoteData):
	"""Create a note instance"""
	var note = Note.new()
	note.lane = note_data.lane
	note.hit_time = note_data.time
	note.is_sustain = note_data.is_sustain
	note.sustain_duration = note_data.sustain_duration
	note.scroll_speed = song_data.scroll_speed * 100  # Scale for visibility
	
	note_container.add_child(note)
	active_notes.append(note)
	
	# Connect signals
	note.note_missed.connect(_on_note_missed)

func update_notes(delta):
	"""Update all active notes"""
	for note in active_notes:
		if is_instance_valid(note):
			note.set_position_from_time(current_song_time, SPAWN_OFFSET_SECONDS)
	
	# Clean up old notes
	active_notes = active_notes.filter(func(n): return is_instance_valid(n))

func hit_note(lane: int):
	"""Check for hittable notes in the given lane"""
	var hit_made = false
	
	for note in active_notes:
		if is_instance_valid(note) and not note.is_hit and note.lane == lane:
			var rating = note.check_hit(current_song_time, HIT_WINDOW)
			
			if rating != "MISS":
				score_manager.register_hit(rating)
				note.mark_as_hit(rating)
				
				# Flash target arrow
				var targets = target_container.get_children()
				if lane < targets.size():
					targets[lane].flash_hit(rating)
				
				hit_made = true
				break
	
	if not hit_made:
		# Optional: Penalize for hitting empty lane
		pass

func _on_note_missed(note: Note):
	"""Handle missed note"""
	if not note.is_hit:
		score_manager.register_miss()
		note.mark_as_missed()

func check_game_state():
	"""Check for game over or song completion"""
	if score_manager.is_game_over():
		end_game(false)
	elif score_manager.is_song_complete():
		end_game(true)

func end_game(success: bool):
	"""End the current song"""
	is_playing = false
	audio_player.stop()
	
	if success:
		song_info_label.text = "COMPLETE! Grade: %s" % score_manager.get_letter_grade()
		print("Song complete! Score: %d, Accuracy: %.1f%%, Grade: %s" % 
			[score_manager.score, score_manager.get_accuracy(), score_manager.get_letter_grade()])
	else:
		song_info_label.text = "FAILED! Try again!"
		print("Game over! Final score: %d" % score_manager.score)

# Signal handlers
func _on_score_changed(new_score: int):
	score_label.text = "Score: %d" % new_score

func _on_combo_changed(new_combo: int):
	if new_combo > 1:
		combo_label.text = "%d COMBO!" % new_combo
	else:
		combo_label.text = ""

func _on_health_changed(new_health: float):
	health_bar.value = new_health * 100

func _on_rating_display(rating: String):
	rating_label.text = rating
	
	# Clear after short delay
	var tween = create_tween()
	tween.tween_interval(0.5)
	tween.tween_property(rating_label, "text", "", 0.2)
