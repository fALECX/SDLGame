class_name Run
extends Node

const MAIN_MENU_SCENE = preload("res://scenes/ui/main_menu.tscn")
const BATTLE_SCENE := preload("res://scenes/battle/battle.tscn")
const BATTLE_REWARD_SCENE := preload("res://scenes/battle_reward/battle_reward.tscn")
const CAMPFIRE_SCENE := preload("res://scenes/campfire/campfire.tscn")
const SHOP_SCENE := preload("res://scenes/shop/shop.tscn")
const TREASURE_SCENE = preload("res://scenes/treasure/treasure.tscn")
const WIN_SCREEN_SCENE := preload("res://scenes/win_screen/win_screen.tscn")
const LOSE_SCREEN_SCENE := preload("res://scenes/win_screen/lose_screen.tscn")
const DESK_SCENE := preload("res://whole_desk.tscn")


@export var run_init_data: RunInitData
@export var save_game: SaveGame	#added for testing
@export var floors_climbed_run: int = 0

@onready var current_view: Node = $CurrentView
@onready var deck_button: CardPileOpener = %DeckButton
@onready var deck_view: CardPileView = %DeckView
@onready var health_ui: HealthUI = %HealthUI
@onready var gold_ui: GoldUI = %GoldUI
@onready var map: Map = $Map
@onready var relic_handler: RelicHandler = %RelicHandler
@onready var relic_tooltip: RelicTooltip = %RelicTooltip
@onready var pause_menu: PauseMenu = $PauseMenu
@onready var topbar = $TopBar
@onready var sprint = $Sprint
@onready var button: Button = %ReturnToDesk
@onready var backgroundimage: CanvasLayer = $BackgroundImage
var stats: RunStats
var character: CharacterStats
var save_data: SaveGame


func _ready() -> void:
	if character:
		_start_run()
	sprint.show()
	pause_menu.save_and_quit.connect(func(): get_tree().change_scene_to_packed(MAIN_MENU_SCENE))
	_initialize_run()
	#Event wenn erste Mal die Szene geladen wird, floors climbed = 0
	print("1. floors changed emit aus ready - run.gd ", floors_climbed() )
	Events.floor_changed.emit(floors_climbed_run)
	Events.get_floors.connect(floors_climbed_no_return)

func _initialize_run() -> void:
	if not run_init_data:
		return
		
	match run_init_data.run_init_type:
		RunInitData.Type.NEW_RUN:
			character = run_init_data.picked_character.create_instance()
			_start_run()
		RunInitData.Type.CONTINUED_RUN:
			_load_run()


func _start_run() -> void:
	RNG.initialize()
	stats = RunStats.new()
	
	_setup_top_bar()
	_setup_event_connections()
	
	map.generate_new_map()
	map.unlock_floor(0)
	
	save_data = SaveGame.new()
	_save_run()


func _save_run():
	save_data.rng_seed = RNG.instance.seed
	save_data.rng_state = RNG.instance.state
	save_data.run_stats = stats
	save_data.char_stats = character
	save_data.current_deck = character.deck
	save_data.current_health = character.health
	save_data.relics = relic_handler.get_all_relics()
	save_data.last_room = map.last_room
	save_data.map_data = map.map_data.duplicate()
	save_data.floors_climbed = map.floors_climbed
	save_data.save_data()


func _load_run() -> void:
	save_data = SaveGame.load_data()
	assert(save_data, "Couldn't load last save")
	
	RNG.set_from_save_data(save_data.rng_seed, save_data.rng_state)
	stats = save_data.run_stats
	character = save_data.char_stats
	character.deck = save_data.current_deck
	character.health = save_data.current_health
	relic_handler.add_relics(save_data.relics)
	_setup_top_bar()
	_setup_event_connections()
	
	map.load_map(save_data.map_data, save_data.floors_climbed, save_data.last_room)
	if save_data.last_room:
		_on_map_exited(save_data.last_room)
	

func _change_view(scene: PackedScene) -> Node:
	if current_view.get_child_count() > 0:
		current_view.get_child(0).queue_free()
	
	get_tree().paused = false # need this because of the battle over panel!
	var new_view := scene.instantiate()
	current_view.add_child(new_view)
	map.hide_map()
	backgroundimage.hide()
	return new_view


func _setup_top_bar() -> void:
	character.stats_changed.connect(health_ui.update_stats.bind(character))
	health_ui.update_stats(character)
	gold_ui.run_stats = stats
	relic_handler.add_relic(character.starting_relic)
	Events.relic_tooltip_requested.connect(relic_tooltip.show_tooltip)
	deck_button.card_pile = character.deck
	deck_view.card_pile = character.deck
	deck_button.pressed.connect(deck_view.show_current_view.bind("Deck"))
	print("top bar setup fertig")

func _show_map() -> void:
	#visible da bei show_whole_desk die topbar auf visible=false gesetzt wird
	%TopBar.visible=true

	if current_view.get_child_count() > 0:
		current_view.get_child(0).queue_free()
	sprint.show()
	map.show_map()
	backgroundimage.show()
	print(floors_climbed(), " floors climbed from show map in run.gd")
	#da sonst unlock_next_rooms nicht funktioniert, da floors_climbed_run noch nicht >0 ist und somit vor erstem level bei aufrufen von whole_desk und zurück auf run_scene fehlermeldung kommt
	if(floors_climbed()>0):
		map.unlock_next_rooms()
	_save_run()


func _setup_event_connections() -> void:
	Events.battle_won.connect(_on_battle_won)
	Events.battle_reward_exited.connect(_show_map)
	Events.campfire_exited.connect(_show_map)
	Events.shop_exited.connect(_show_map)
	Events.map_exited.connect(_on_map_exited)
	Events.desk_exited.connect(_show_map)

	Events.treasure_room_exited.connect(_on_treasure_room_exited)

#added function to show floors climbed
func _show_regular_battle_rewards() -> void:
	%TopBar.visible = false
	var reward_scene := _change_view(BATTLE_REWARD_SCENE) as BattleReward
	reward_scene.run_stats = stats
	reward_scene.character_stats = character
	reward_scene.relic_handler = relic_handler
	print(floors_climbed(), "floors climbed from battle rewards in run.gd")
	reward_scene.add_gold_reward(map.last_room.battle_stats.roll_gold_reward())
	print("floors changed emit aus show regular battle rewards - run.gd")
	print(floors_climbed_run)
	#floors changed emit nach battle rewards plus nach erstem mal szene laden (_ready)
	Events.floor_changed.emit(floors_climbed_run)


func floors_climbed_no_return() -> void:
	floors_climbed_run = map.floors_climbed
	print("send floors emit aus floors_climbed_no_return in run.gd: floors: ", floors_climbed_run)
	Events.send_floors.emit(floors_climbed_run)


func floors_climbed() -> int:
	floors_climbed_run = map.floors_climbed
	Events.send_floors.emit(map.floors_climbed)
	return map.floors_climbed


func  _on_battle_room_entered(room: Room) -> void:
	#var offset: Vector2 = Vector2(-100,-100)
	#topbar.set_offset(offset)
	topbar.visible = false
	print(floors_climbed(), "  floors climbed from battle room entered")
	#Events.floor_changed.connect(character_stats._on_floor_changed)

	var battle_scene: Battle = _change_view(BATTLE_SCENE) as Battle
	battle_scene.char_stats = character
	battle_scene.battle_stats = room.battle_stats
	battle_scene.relics = relic_handler
	battle_scene.start_battle()


func _on_campfire_entered() -> void:
	var campfire := _change_view(CAMPFIRE_SCENE) as Campfire
	campfire.char_stats = character


func _on_shop_entered() -> void:
	var shop := _change_view(SHOP_SCENE) as Shop
	shop.char_stats = character
	shop.run_stats = stats
	shop.relic_handler = relic_handler
	Events.shop_entered.emit(shop)
	shop.populate_shop()


func _on_battle_won() -> void:
	#wenn mind. 120 Kundenzufriedenheit, dann Win screen, char anzeigen und game delete data
	print("on battle won from run.gd: map.floors_climbed: ", map.floors_climbed, " and MapGenerator.FLOORS: ", MapGenerator.FLOORS)
	if(map.floors_climbed == MapGenerator.FLOORS):
		print("floors_climbed == MapGenerator.FLOORS triggered")
		if(stats.gold > 250):
			print("gold > 120 triggered")
			var win_screen := _change_view(WIN_SCREEN_SCENE) as WinScreen
			win_screen.character = character
			SaveGame.delete_data()
		if(stats.gold <= 250):
			print("gold <= 120 triggered")
			var lose_screen := _change_view(LOSE_SCREEN_SCENE) as LoseScreen
			lose_screen.character = character
			SaveGame.delete_data()
		#wenn nicht aktueller floor == insg. floors, dann map unlock next rooms
	else:
		#edited dass event signal emitted wird, dass anzeigt dass floor besiegt wurde und somit rewards aus dem array des spezifischen sprints ausgegeben werden
		Events.change_cards.emit(floors_climbed_run)
		_show_regular_battle_rewards()


func _on_treasure_room_entered() -> void:
	var treasure_scene := _change_view(TREASURE_SCENE) as Treasure
	treasure_scene.relic_handler = relic_handler
	treasure_scene.char_stats = character
	treasure_scene.generate_relic()


func _on_treasure_room_exited(relic: Relic) -> void:
	var reward_scene := _change_view(BATTLE_REWARD_SCENE) as BattleReward
	reward_scene.run_stats = stats
	reward_scene.character_stats = character
	reward_scene.relic_handler = relic_handler
	
	reward_scene.add_relic_reward(relic)


func _on_map_exited(room: Room) -> void:
	_save_run()
	
	match room.type:
		Room.Type.MONSTER:
			_on_battle_room_entered(room)
		Room.Type.TREASURE:
			_on_treasure_room_entered()
		Room.Type.CAMPFIRE:
			_on_campfire_entered()
		Room.Type.SHOP:
			_on_shop_entered()
		Room.Type.BOSS:
			_on_battle_room_entered(room)

func _on_return_to_desk_pressed() -> void:
	%TopBar.visible=false
	_change_view(DESK_SCENE)
