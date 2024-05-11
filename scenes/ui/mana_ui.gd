class_name ManaUI
extends Panel

#preload a texture
var mana_icon3 = preload("res://art/Mana 3.png")
var mana_icon2 = preload("res://art/Mana 2.png")
var mana_icon1 = preload("res://art/Mana 1.png")

@export var char_stats: CharacterStats : set = set_char_stats

@onready var mana_label: Label = $ManaLabel
@onready var mana_icon: TextureRect = $ManaIcon

func set_char_stats(value: CharacterStats) -> void:
	char_stats = value
	
	if not char_stats.stats_changed.is_connected(_on_stats_changed):
		char_stats.stats_changed.connect(_on_stats_changed)

	if not is_node_ready():
		await ready

	_on_stats_changed()


func _on_stats_changed() -> void:
	mana_label.text = "%s/%s" % [char_stats.mana, char_stats.max_mana]
	if char_stats.mana == 2:
		$ManaIcon.texture = ResourceLoader.load("res://art/Mana 2.png")
	if char_stats.mana == 3:
		$ManaIcon.texture = ResourceLoader.load("res://art/Mana 3.png")
	if char_stats.mana == 1:
		$ManaIcon.texture = ResourceLoader.load("res://art/Mana 1.png")
