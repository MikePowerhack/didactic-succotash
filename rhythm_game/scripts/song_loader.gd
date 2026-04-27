class_name SongLoader
extends RefCounted

## Utility class for loading and managing songs
## Provides methods to scan directories, load song data, and manage playlists
## This modular approach makes it easy to add song selection menus

static func create_test_song() -> SongData:
	"""Create a simple test song for immediate playability"""
	var song = SongData.new()
	song.song_name = "Tutorial Track"
	song.artist = "Dev Team"
	song.bpm = 120.0
	song.scroll_speed = 4.0
	song.difficulty = 1
	
	# Generate a simple pattern
	var beat_duration = 60.0 / song.bpm
	
	# Intro (no notes)
	# Then simple alternating pattern
	for i in range(8, 40):
		var note = NoteData.new()
		note.time = i * beat_duration
		note.lane = i % 4
		song.notes.append(note)
	
	# Add some doubles
	for i in range(40, 60):
		var note1 = NoteData.new()
		note1.time = i * beat_duration
		note1.lane = i % 4
		song.notes.append(note1)
		
		if i % 3 == 0:
			var note2 = NoteData.new()
			note2.time = i * beat_duration
			note2.lane = (i + 2) % 4
			song.notes.append(note2)
	
	print("Created test song with ", song.notes.size(), " notes")
	return song

static func create_practice_song() -> SongData:
	"""Create a slow practice song for learning"""
	var song = SongData.new()
	song.song_name = "Practice Mode"
	song.artist = "Training"
	song.bpm = 80.0
	song.scroll_speed = 3.0
	song.difficulty = 1
	
	var beat_duration = 60.0 / song.bpm
	
	# Very simple pattern - one lane at a time
	var patterns = [0, 1, 2, 3, 3, 2, 1, 0]
	for i in range(16):
		var note = NoteData.new()
		note.time = (i + 4) * beat_duration
		note.lane = patterns[i % patterns.size()]
		song.notes.append(note)
	
	return song

static func create_hard_song() -> SongData:
	"""Create a challenging song for experienced players"""
	var song = SongData.new()
	song.song_name = "Challenge Track"
	song.artist = "Hard Mode"
	song.bpm = 160.0
	song.scroll_speed = 6.0
	song.difficulty = 3
	
	var beat_duration = 60.0 / song.bpm
	
	# Fast streams and jumps
	for i in range(10, 100):
		# Main stream
		var note = NoteData.new()
		note.time = i * beat_duration * 0.5  # Half beats
		note.lane = i % 4
		song.notes.append(note)
		
		# Add jumps on offbeats
		if i % 5 == 0:
			var jump = NoteData.new()
			jump.time = i * beat_duration * 0.5
			jump.lane = (i + 2) % 4
			song.notes.append(jump)
	
	return song

static func save_song_to_file(song: SongData, path: String) -> Error:
	"""Save a song to a resource file"""
	var err = ResourceSaver.save(song, path)
	if err == OK:
		print("Song saved to: ", path)
	else:
		print("Failed to save song: ", err)
	return err

static func load_song_from_file(path: String) -> SongData:
	"""Load a song from a resource file"""
	var song = ResourceLoader.load(path) as SongData
	if song:
		print("Loaded song: ", song.song_name)
	else:
		print("Failed to load song from: ", path)
	return song

static func get_all_songs_in_directory(dir_path: String) -> Array[SongData]:
	"""Scan a directory for all SongData resources"""
	var songs: Array[SongData] = []
	
	if not DirAccess.dir_exists_absolute(dir_path):
		print("Directory not found: ", dir_path)
		return songs
	
	var dir = DirAccess.open(dir_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.ends_with(".tres") or file_name.ends_with(".res"):
				var full_path = dir_path.trim_suffix("/") + "/" + file_name
				var resource = ResourceLoader.load(full_path)
				if resource is SongData:
					songs.append(resource)
			file_name = dir.get_next()
		
		dir.list_dir_end()
	
	print("Found ", songs.size(), " songs in ", dir_path)
	return songs
