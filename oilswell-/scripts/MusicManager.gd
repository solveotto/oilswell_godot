extends Node

@onready var music_player: AudioStreamPlayer
@onready var bip: AudioStreamPlayer
@onready var monster_sound: AudioStreamPlayer
@onready var timestop_sound: AudioStreamPlayer
@onready var next_level_sound: AudioStreamPlayer

const BIP = preload("res://assests/sfx/bip.wav")
const DRONE = preload("res://assests/sfx/drone.mp3")
const MONSTER_DEATH = preload("res://assests/sfx/monster_death.wav")
const TIMESTOP = preload("res://assests/sfx/Timestop.wav")
const NEW_LEVEL = preload("res://assests/sfx/new_level.mp3")

func _ready():
	# Create and configure the AudioStreamPlayer
	music_player = AudioStreamPlayer.new()
	bip = AudioStreamPlayer.new()
	add_child(music_player)
	add_child(bip)
	
	music_player.stream = DRONE  # Replace with your music file
	music_player.volume_db = -10  # Adjust volume if needed
	music_player.bus = "Music"  # Ensure it plays on the correct audio bus
	music_player.autoplay = true
	
		# Enable looping on the AudioStream, NOT AudioStreamPlayer
	if music_player.stream is AudioStream:
		music_player.stream.set_loop(true)
	
	bip.stream = BIP
		
	music_player.play()
	
	monster_sound = create_stream(MONSTER_DEATH, -15, "SFX")
	timestop_sound = create_stream(TIMESTOP, -12, "SFX")
	next_level_sound = create_stream(NEW_LEVEL, -12, "SFX")
	

func create_stream(sound_file, volum_db:int, bus:String, autoplay=false, loop=false):
	var new_sound = AudioStreamPlayer.new()
	
	new_sound.stream = sound_file
	new_sound.volume_db = volum_db
	new_sound.bus = bus

	add_child(new_sound)
	
	return new_sound


func play_music():
	if not music_player.playing:
		music_player.play()

func stop_music():
	music_player.stop()

func play_bip():
	if not bip.playing:
		bip.play()
