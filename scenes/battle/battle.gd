class_name Battle
extends Node2D

@export var battle_stats: BattleStats
@export var char_stats: CharacterStats
@export var relics: RelicHandler
@export var music: AudioStream

@onready var battle_ui: BattleUI = $BattleUI
@onready var player_handler: PlayerHandler = $PlayerHandler
@onready var enemy_handler: EnemyHandler = $EnemyHandler
@onready var player: Player = $Player
@onready var battle_1: Sprite2D = $Battle1Skype
@onready var battle_2: Sprite2D = $Battle2Office
@onready var battle_3: Sprite2D = $Battle3Server
@onready var battle_4: Sprite2D = $Battle4Server
@onready var battle_5: Sprite2D = $Battle5Server
@onready var battle_6: Sprite2D = $Battle6Server
@onready var battle_7: Sprite2D = $Battle7Server
@onready var battle_8: Sprite2D = $Battle8Server
@onready var backgroundcardgrid: Sprite2D = $BackgroundDotGridCards
@onready var sprintstory: CanvasLayer = $SprintStory
@onready var einleitung: Sprite2D = %Einleitung
var floors_climbed := 0

func _ready() -> void:
	print("ready aus battle.gd aufgerufen")
	enemy_handler.child_order_changed.connect(_on_enemies_child_order_changed)
	Events.enemy_turn_ended.connect(_on_enemy_turn_ended)

	Events.send_floors.connect(floors_climbed_update)
	Events.floor_changed.connect(floors_climbed_changed)

	Events.player_turn_ended.connect(player_handler.end_turn)
	Events.player_hand_discarded.connect(enemy_handler.start_turn)
	Events.player_died.connect(_on_player_died)

	print("get_floors emit aus ready von batttle.gd")
	Events.get_floors.emit()
	print("floors from battle.gd: ", floors_climbed)


func floors_climbed_update(floors :int) -> void:
	print("send_floors connect von battle.gd aufgerufen: ", floors)
	floors_climbed = floors
	if(floors_climbed == 1):
		print("Hide player emit from floors_climbed_changed from battle.gd")
		Events.hide_player.emit()
		battle_1.visible = true
		sprintstory.visible = true
		%Einleitung.visible = true
		backgroundcardgrid.visible = false
	if(floors_climbed == 2):
		backgroundcardgrid.visible = true
		battle_2.visible = true
		sprintstory.visible = true
		%AlterBekannter1.visible = true
		%AlterBekannter2.visible = true
		Events.show_player.emit()
	if(floors_climbed == 3):
		backgroundcardgrid.visible = true
		%Cybercrime.visible = true
		sprintstory.visible = true
		battle_3.visible = true
		Events.show_player.emit()
	if(floors_climbed == 4):
		sprintstory.visible = true
		backgroundcardgrid.visible = true
		%BugHunting.visible = true
		battle_4.visible = true
		Events.show_player.emit()
	if(floors_climbed == 5):
		sprintstory.visible = true
		backgroundcardgrid.visible = true
		%TrojanHorse.visible = true
		battle_5.visible = true
		Events.show_player.emit()
	if(floors_climbed == 6):
		sprintstory.visible = true
		backgroundcardgrid.visible = true
		%Release.visible = true
		battle_6.visible = true
		Events.show_player.emit()
	if(floors_climbed == 7):
		sprintstory.visible = true
		backgroundcardgrid.visible = true
		%Gegnerteam.visible = true
		battle_7.visible = true
		Events.show_player.emit()
	if(floors_climbed == 8):
		backgroundcardgrid.visible = true
		battle_7.visible = true
		Events.show_player.emit()

func floors_climbed_changed(floors_given: int) -> void:
	print("Floor changed from battle.gd: ", floors_given)
	floors_climbed = floors_given

func _on_to_battle_button_pressed() -> void:
	if floors_climbed == 2 and %AlterBekannter1.visible == true:
		%AlterBekannter1.visible = false
	else:
		sprintstory.visible = false

func start_battle() -> void:
	get_tree().paused = false
	MusicPlayer.play(music, true)
	
	battle_ui.char_stats = char_stats
	player.stats = char_stats
	player_handler.relics = relics
	enemy_handler.setup_enemies(battle_stats)
	enemy_handler.reset_enemy_actions.call_deferred()
	
	relics.relics_activated.connect(_on_relics_activated)
	relics.activate_relics_by_type(Relic.Type.START_OF_COMBAT)


func _on_enemies_child_order_changed() -> void:
	if enemy_handler.get_child_count() == 0 and is_instance_valid(relics):
		relics.activate_relics_by_type(Relic.Type.END_OF_COMBAT)


func _on_enemy_turn_ended() -> void:
	player_handler.start_turn()
	enemy_handler.reset_enemy_actions()


func _on_player_died() -> void:
	Events.battle_over_screen_requested.emit("Sprint nicht geschafft!", BattleOverPanel.Type.LOSE)
	SaveGame.delete_data()


func _on_relics_activated(type: Relic.Type) -> void:
	match type:
		Relic.Type.START_OF_COMBAT:
			player_handler.start_battle(char_stats)
			battle_ui.initialize_card_pile_ui()
		Relic.Type.END_OF_COMBAT:
			Events.battle_over_screen_requested.emit("Sprint bestanden!", BattleOverPanel.Type.WIN)
