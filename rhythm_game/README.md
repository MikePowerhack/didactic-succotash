# Rhythm Game - README

## Overview
A modular rhythm game inspired by Friday Night Funkin', built in Godot 4.6. This project is designed to be easily extensible, allowing you to add custom songs, modify gameplay mechanics, and expand features.

## Quick Start

### Running the Game
1. Open the project in Godot 4.6+
2. Set `res://scenes/Main.tscn` as the main scene (already configured)
3. Press F5 or click "Play"
4. Click "PLAY" on the main menu
5. Press SPACE to start the song
6. Hit notes with **WASD** or **Arrow Keys**

### Controls
- **W/Up Arrow**: Hit top note
- **S/Down Arrow**: Hit bottom note  
- **A/Left Arrow**: Hit left note
- **D/Right Arrow**: Hit right note
- **SPACE/Enter**: Start game / Confirm
- **ESC**: Pause/Resume

## Project Structure

```
rhythm_game/
├── project.godot          # Project configuration
├── scenes/                # Scene files (.tscn)
│   ├── Main.tscn         # Entry point
│   ├── MainMenu.tscn     # Main menu
│   └── Game.tscn         # Gameplay scene
├── scripts/              # All game scripts
│   ├── main.gd           # Bootstrapper
│   ├── main_menu.gd      # Menu controller
│   ├── game_scene.gd     # Main gameplay logic
│   ├── note.gd           # Note visual & logic
│   ├── note_data.gd      # Note data resource
│   ├── song_data.gd      # Song container resource
│   ├── target_arrow.gd   # Target arrow visuals
│   ├── score_manager.gd  # Scoring system
│   └── song_loader.gd    # Song creation utilities
├── assets/               # Place your audio/images here
└── songs/                # Custom song resources
```

## Core Systems

### 1. SongData Resource
The heart of the modularity. Each song is a `SongData` resource containing:
- Song metadata (name, artist, BPM)
- Audio stream reference
- Array of NoteData objects
- Difficulty and scroll speed settings

### 2. Note System
- **NoteData**: Pure data (time, lane, sustain info)
- **Note**: Visual representation with hit detection
- Notes spawn based on timing and scroll toward targets

### 3. Scoring
- Ratings: SICK, GOOD, BAD, MISS
- Combo system with bonus points
- Health bar that depletes on misses
- Letter grades (S, A, B, C, D, F)

### 4. Input Handling
- Supports both keyboard (WASD) and arrow keys
- Configurable hit windows
- Visual feedback on targets

## Adding Custom Songs

### Method 1: Using SongLoader (Programmatic)
```gdscript
var song = SongLoader.create_test_song()
game_instance.song_data = song
```

### Method 2: Create Resource File
1. In Godot, right-click in FileSystem
2. Create → Resource → SongData
3. Configure properties:
   - Set song name, artist, BPM
   - Add audio file
   - Create NoteData entries
4. Save as `.tres` file in `songs/` folder

### Method 3: Code-Generated Songs
Create a new script extending RefCounted:

```gdscript
class_name MyCustomSong
extends RefCounted

static func create() -> SongData:
    var song = SongData.new()
    song.song_name = "My Song"
    song.bpm = 140.0
    
    # Add notes
    for i in range(100):
        var note = NoteData.new()
        note.time = i * (60.0 / song.bpm)
        note.lane = randi() % 4
        song.notes.append(note)
    
    return song
```

## Extending the Game

### Adding New Features
All scripts are heavily commented and modular:

- **New Note Types**: Extend `NoteData` with new properties
- **Custom Scoring**: Modify `ScoreManager` constants
- **Visual Effects**: Add particles in `Note.mark_as_hit()`
- **New Lanes**: Update `LANE_NAMES` and input mappings
- **Hold Notes**: Implement using `is_sustain` flag

### Example: Changing Hit Windows
Edit `game_scene.gd`:
```gdscript
const HIT_WINDOW: float = 0.15  # Make smaller for harder gameplay
```

### Example: Custom Scroll Speeds
In `SongData`, set different `scroll_speed` values per song.

### Example: Adding Sound Effects
In `note.gd`, add:
```gdscript
@export var hit_sound: AudioStream
func mark_as_hit(rating: String):
    if hit_sound:
        AudioServer.play_stream(hit_sound)
```

## Configuration

### Input Mapping
Input actions are defined in `project.godot`:
- `left`: A / Left Arrow
- `down`: S / Down Arrow
- `up`: W / Up Arrow
- `right`: D / Right Arrow
- `accept`: Space / Enter

### Difficulty Tuning
Adjust these in `score_manager.gd`:
```gdscript
const SCORE_SICK = 350
const HEALTH_SICK = 0.15
const HEALTH_MISS = -0.15
```

## Troubleshooting

### No Audio?
- The test song works without audio
- Add an AudioStream to SongData.audio_stream for music
- Supported formats: .ogg, .wav, .mp3

### Notes Not Spawning?
- Check that song has notes in `song_data.notes`
- Verify BPM is set correctly
- Ensure scroll_speed > 0

### Performance Issues?
- Reduce SPAWN_OFFSET_SECONDS to spawn fewer notes
- Use object pooling for notes (advanced)
- Lower texture quality if using images

## Next Steps

1. **Add Music**: Import audio files to `assets/`
2. **Create Songs**: Use the SongLoader or create resources
3. **Customize Visuals**: Replace ColorRects with sprites
4. **Add Menus**: Expand main menu with song selection
5. **Implement Holds**: Complete sustain note logic
6. **Add Effects**: Particles, screen shake, combo effects

## License
This is a template project. Use it freely for your own games!

## Support
For issues or questions, check the Godot documentation or community forums.

Happy coding! 🎵
