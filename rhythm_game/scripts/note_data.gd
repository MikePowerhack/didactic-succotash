class_name NoteData
extends Resource

## Represents a single note in the rhythm game
## This resource is used to define when and which arrow should appear

@export var time: float = 0.0  # Time in seconds when the note should be hit
@export var lane: int = 0      # Lane index (0=Left, 1=Down, 2=Up, 3=Right)
@export var is_sustain: bool = false  # Whether this is a hold note
@export var sustain_duration: float = 0.0  # Duration of sustain in seconds
