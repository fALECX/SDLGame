class_name SaveGame
extends Resource

const SAVE_PATH := "user://savegame.tres"

@export var rng_seed: int
@export var rng_state: int
@export var run_stats: RunStats
@export var char_stats: CharacterStats
@export var current_deck: CardPile
@export var current_health: int
@export var relics: Array[Relic]
@export var map_data: Array[Array]
@export var last_room: Room
@export var floors_climbed: int


func save_data() -> void:
	var err := ResourceSaver.save(self, SAVE_PATH)
	assert(err == OK, "Couldn't save the game!")


static func load_data() -> SaveGame:
	if FileAccess.file_exists(SAVE_PATH):
		return ResourceLoader.load(SAVE_PATH) as SaveGame
	
	return null


static func delete_data() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)

func get_floors_climbed() -> String:
	if FileAccess.file_exists(SAVE_PATH):
		var savegame := ResourceLoader.load(SAVE_PATH) as SaveGame
		print("test")
		return str(savegame.floors_climbed)
	print("tes2t2")
	return str(0)