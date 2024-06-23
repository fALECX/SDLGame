class_name RunStats
extends Resource

signal zufriedenheit_changed
signal sprint_changed

const start_kundenzufriedenheit := 0
#karten rewards, 15.05.2024 fest auf 5 da CardPile Karten Array somit 2 richtige und 3 falsche anzeigen kann - benötigt für implementation des picken der falschen Karte
const BASE_CARD_REWARDS := 5
const BASE_COMMON_WEIGHT := 6.0
const BASE_UNCOMMON_WEIGHT := 3.7
const BASE_RARE_WEIGHT := 0.3

@export var kundenzufriedenheit := start_kundenzufriedenheit : set = set_gold
@export var card_rewards := BASE_CARD_REWARDS
@export_range(0.0, 10.0) var common_weight := BASE_COMMON_WEIGHT
@export_range(0.0, 10.0) var uncommon_weight := BASE_UNCOMMON_WEIGHT
@export_range(0.0, 10.0) var rare_weight := BASE_RARE_WEIGHT


func set_gold(new_amount: int) -> void:
	kundenzufriedenheit = new_amount
	zufriedenheit_changed.emit()


func reset_weights() -> void:
	common_weight = BASE_COMMON_WEIGHT
	uncommon_weight = BASE_UNCOMMON_WEIGHT
	rare_weight = BASE_RARE_WEIGHT
