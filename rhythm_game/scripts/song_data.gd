class_name SongData
extends Resource

## Contains all data for a single song/level
## This modular design allows easy addition of new songs

@export var song_name: String = "Untitled"
@export var artist: String = "Unknown"
@export var bpm: float = 120.0
@export var audio_stream: AudioStream  # The music file
@export var notes: Array[NoteData] = []  # All notes in the song
@export var difficulty: int = 1  # 1=Easy, 2=Normal, 3=Hard
@export var scroll_speed: float = 5.0  # How fast notes scroll down

# Helper function to get notes sorted by time
func get_sorted_notes() -> Array[NoteData]:
	var sorted_notes = notes.duplicate()
	sorted_notes.sort_custom(func(a, b): return a.time < b.time)
	return sorted_notes

# Get notes within a time range (useful for spawning/despawning)
func get_notes_in_range(start_time: float, end_time: float) -> Array[NoteData]:
	var result: Array[NoteData] = []
	for note in notes:
		if note.time >= start_time and note.time <= end_time:
			result.append(note)
	return result
