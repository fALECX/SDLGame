class_name BattleReward
extends Control

#generates cards for card_rewards

const REWARD_BUTTON = preload("res://scenes/ui/reward_button.tscn")
const REWARD_BUTTON_DATA := {
	Type.GOLD: [preload("res://art/Customer Satisfaction.png"), "%s Kundenzufriedenheit"],
	Type.NEW_CARD: [preload("res://art/User Story 3.png"), "Was hast du in diesem Sprint erreicht?"]
}

#added these 24.04.2024 to add custom label and icon for sprint
const SPRINT_LABEL = preload("res://scenes/ui/sprint_label.tscn")
const SPRINT_ICON = preload("res://art/sprint_icon.png")
const SPRINT_LABEL_TEXT = "Sprint %s"

#deleted relic enum, RELIC
enum Type {GOLD, NEW_CARD}

@export var run_stats: RunStats
@export var character_stats: CharacterStats
@export var relic_handler: RelicHandler
@export var map : Map
@export var save_game : SaveGame
@export var run: Run  # Add a reference to the Run instance
#fyi Hbox will order the contents horizontally, Vbox will order the contents of box vertically
@onready var rewards: VBoxContainer = %Rewards
@onready var card_rewards: CardRewards = %CardRewards
@onready var label: Label = %Label


var floors_climbed := 0
var card_reward_total_weight := 0.0
var card_rarity_weights := {
	Card.Rarity.COMMON: 0.0,
	Card.Rarity.UNCOMMON: 0.0,
	Card.Rarity.RARE: 0.0
}


func _ready() -> void:

	Events.floor_changed.connect(_change_label_title)
	print("battle reward scene entered")
	for node: Node in rewards.get_children():
		node.queue_free()

	print("nach free queue")

	run_stats = RunStats.new()
	run_stats.gold_changed.connect(func(): print("gold: %s" % run_stats.gold))
	character_stats = preload("res://characters/warrior/warrior.tres").create_instance()
	card_rewards.card_reward_selected.connect(_on_card_reward_taken)
	#print("aus ready von battle_reward.gd: lade custom draftable cards")
	#character_stats.draftable_cards = load("res://characters/warrior/draftablecardssprint1.tres")
	print()
	#testing purposes, wenn ausschliesslich dieses szene abgespielt wird
	#add_gold_reward(-20)
	add_card_reward()
	Events.floor_changed.connect(update_floors_climbed)


func _change_label_title(floors: int) -> void:
	label.text = "Sprint " + str(floors) + " Belohnungen"

func update_floors_climbed(floors: int) -> void:
	floors_climbed = floors

func add_gold_reward(amount: int) -> void:
	var gold_reward := REWARD_BUTTON.instantiate() as RewardButton

	#wichtig: übergabe von daten an reward_button !!!
	gold_reward.reward_icon = REWARD_BUTTON_DATA[Type.GOLD][0]
	gold_reward.reward_text = REWARD_BUTTON_DATA[Type.GOLD][1] % amount
	gold_reward.pressed.connect(_on_gold_reward_taken.bind(amount))
	rewards.add_child.call_deferred(gold_reward)


func add_card_reward() -> void:
	var card_reward := REWARD_BUTTON.instantiate() as RewardButton
	card_reward.reward_icon = REWARD_BUTTON_DATA[Type.NEW_CARD][0]
	card_reward.reward_text = REWARD_BUTTON_DATA[Type.NEW_CARD][1]
	card_reward.pressed.connect(_show_card_rewards)
	rewards.add_child.call_deferred(card_reward)


func add_relic_reward(relic: Relic) -> void:
	var relic_reward := REWARD_BUTTON.instantiate() as RewardButton
	relic_reward.reward_icon = relic.icon
	relic_reward.reward_text = relic.relic_name
	relic_reward.pressed.connect(_on_relic_reward_taken.bind(relic))
	rewards.add_child.call_deferred(relic_reward)


func _show_card_rewards() -> void:
	#safety check - we have runstats and characterstats available
	if not run_stats or not character_stats:
		return

	#if (floors_climbed == 1):
		#print("aus show card rewards: custom array geladen")
		#character_stats.draftable_cards = load("res://characters/warrior/draftablecardssprint1.tres")
	match floors_climbed:
		1:
			print("fc1: aus show card rewards: custom array geladen")
			character_stats.draftable_cards = load("res://characters/warrior/draftablecardssprint1.tres")
		2:
			print("fc2: aus show card rewards: custom array geladen")
			character_stats.draftable_cards = load("res://characters/warrior/draftablecardssprint2.tres")
		3:
			print("fc3: aus show card rewards: custom array geladen")
			character_stats.draftable_cards = load("res://characters/warrior/draftablecardssprint3.tres")
		4:
			print("fc4: aus show card rewards: custom array geladen")
			character_stats.draftable_cards = load("res://characters/warrior/draftablecardssprint4.tres")
		5:
			print("fc5: aus show card rewards: custom array geladen")
			character_stats.draftable_cards = load("res://characters/warrior/draftablecardssprint5.tres")
		6:
			print("fc6: aus show card rewards: custom array geladen")
			character_stats.draftable_cards = load("res://characters/warrior/draftablecardssprint6.tres")
		7:
			print("fc7: aus show card rewards: custom array geladen")
			character_stats.draftable_cards = load("res://characters/warrior/draftablecardssprint7.tres")
		8:
			print("fc8: aus show card rewards: custom array geladen")
			character_stats.draftable_cards = load("res://characters/warrior/draftablecardssprint7.tres")

	var card_reward_array: Array[Card] = []
	var available_cards := character_stats.draftable_cards.cards.duplicate(true)

	for i in run_stats.card_rewards:
		_setup_card_chances()
		var roll := RNG.instance.randf_range(0.0, card_reward_total_weight)
		
		for rarity: Card.Rarity in card_rarity_weights:
			if card_rarity_weights[rarity] > roll:
				_modify_weights(rarity)
				var picked_card := _get_random_available_card(available_cards, rarity)
				card_reward_array.append(picked_card)
				available_cards.erase(picked_card)
				break

	card_rewards.rewards = card_reward_array
	card_rewards.show()
	

func _setup_card_chances() -> void:
	card_reward_total_weight = run_stats.common_weight + run_stats.uncommon_weight + run_stats.rare_weight
	card_rarity_weights[Card.Rarity.COMMON] = run_stats.common_weight
	card_rarity_weights[Card.Rarity.UNCOMMON] = run_stats.common_weight + run_stats.uncommon_weight
	card_rarity_weights[Card.Rarity.RARE] = card_reward_total_weight


func _modify_weights(rarity_rolled: Card.Rarity) -> void:
	if rarity_rolled == Card.Rarity.RARE:
		run_stats.rare_weight = RunStats.BASE_RARE_WEIGHT
	else:
		run_stats.rare_weight = clampf(run_stats.rare_weight + 0.3, run_stats.BASE_RARE_WEIGHT, 5.0)


func _get_random_available_card(available_cards: Array[Card], with_rarity: Card.Rarity) -> Card:
	# verfügbare karten = alle
	var all_possible_cards := available_cards

	# verfügbare karten = alle mit rarity die mitgegeben wird
	#var all_possible_cards := available_cards.filter(
	#	func(card: Card):
	#		return card.rarity == with_rarity
	#)
	return RNG.array_pick_random(all_possible_cards)


func _on_gold_reward_taken(amount: int) -> void:
	if not run_stats:
		return

	run_stats.gold += amount


var cards_taken := 0

func _on_card_reward_taken(card: Card) -> void:
	if not character_stats or not card:
		return

	character_stats.deck.add_card(card)
	cards_taken += 1

	#Karte wurde gepickt und potentielle negative Effekte wurden ausgelöst und angezeigt -> WrongCardPopup.gd
	print("aus battle_reward.gd: Karte wurde gepickt und potentielle negative Effekte wurden ausgelöst und angezeigt")
	Events.card_taken.emit(card)



	if cards_taken < 3:
		card_rewards.show()  # show the card rewards screen again
	else:
		_on_back_button_pressed()

func _on_relic_reward_taken(relic: Relic) -> void:
	if not relic or not relic_handler:
		return
		
	relic_handler.add_relic(relic)


func _on_back_button_pressed() -> void:
	Events.battle_reward_exited.emit()


