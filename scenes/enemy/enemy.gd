class_name Enemy
extends Area2D

const ARROW_OFFSET := 5
const WHITE_SPRITE_MATERIAL := preload("res://art/white_sprite_material.tres")

@export var stats: EnemyStats : set = set_enemy_stats

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var arrow: Sprite2D = $Arrow
@onready var stats_ui: StatsUI = $StatsUI
@onready var intent_ui: IntentUI = $IntentUI
@onready var status_handler: StatusHandler = $StatusHandler
@onready var modifier_handler: ModifierHandler = $ModifierHandler
@onready var collisionshape: CollisionShape2D = $CollisionShape2D

var enemy_action_picker: EnemyActionPicker
var current_action: EnemyAction : set = set_current_action
var floors_climbed: int = 3

func _ready() -> void:

	print("ready aus enemy.gd called")
	print("floors_climbed from ready in enemy.gd: ", floors_climbed)
	status_handler.status_owner = self
	Events.get_floors.emit()
	Events.send_floors.connect(set_floors_climbed)
	set_sprite_sizes()

func set_floors_climbed(value: int) -> void:
	floors_climbed = value
	print("value: ", value)
	#set_sprite_sizes()

func set_sprite_sizes() -> void:
	Events.get_floors.emit()
	print("floors_climbed from set_sprite_sizes() enemy.gd: ", floors_climbed)
	if(floors_climbed == 0):
		print("if clause triggered in set_sprite_size() enemy.gd: 0")
		collisionshape.scale = Vector2(7,5)
		collisionshape.position = Vector2(-55,-30)
		stats_ui.scale = Vector2(2,2)
		stats_ui.position = Vector2(-150, 0)
		intent_ui.position = Vector2(-85,-100)
		arrow.scale = Vector2(3,3)
		sprite_2d.visible = false
	if(floors_climbed == 1):
		print("if clause triggered in set_sprite_size() enemy.gd: 1")
		collisionshape.scale = Vector2(7,5)
		collisionshape.position = Vector2(15,-10)
		stats_ui.scale = Vector2(2,2)
		stats_ui.position = Vector2(-65, 30)
		intent_ui.position = Vector2(0,-75)
		arrow.scale = Vector2(3,3)
		sprite_2d.visible = false
	if(floors_climbed == 2):
		collisionshape.scale = Vector2(7,5)
		collisionshape.position = Vector2(15,-10)
		stats_ui.scale = Vector2(2,2)
		stats_ui.position = Vector2(-65, 30)
		intent_ui.position = Vector2(0,-75)
		arrow.scale = Vector2(3,3)
	if(floors_climbed == 3):
		intent_ui.scale = Vector2(0.7,0.7)
		intent_ui.position = Vector2(-15,-40)
		arrow.scale = Vector2(3,3)
		stats_ui.position = Vector2(-43,18)
	#skalierung von ui und sprite hide wenn sprint 1 (skype szene)
func set_enemy_size(value: int) -> void:
	print(value)
	if(value == 1):
		stats_ui.scale = Vector2(2,2)
		intent_ui.position = Vector2(75,-65)

func set_current_action(value: EnemyAction) -> void:
	current_action = value
	if current_action:
		update_intent()


func set_enemy_stats(value: EnemyStats) -> void:
	stats = value.create_instance()
	
	if not stats.stats_changed.is_connected(update_stats):
		stats.stats_changed.connect(update_stats)
		stats.stats_changed.connect(update_action)
	
	update_enemy()


func setup_ai() -> void:
	if enemy_action_picker:
		enemy_action_picker.queue_free()
		
	var new_action_picker := stats.ai.instantiate() as EnemyActionPicker
	add_child(new_action_picker)
	enemy_action_picker = new_action_picker
	enemy_action_picker.enemy = self


func update_stats() -> void:
	stats_ui.update_stats(stats)


func update_action() -> void:
	if not enemy_action_picker:
		return
	
	if not current_action:
		current_action = enemy_action_picker.get_action()
		return
	
	var new_conditional_action := enemy_action_picker.get_first_conditional_action()
	if new_conditional_action and current_action != new_conditional_action:
		current_action = new_conditional_action


func update_enemy() -> void:
	if not stats is Stats: 
		return
	if not is_inside_tree(): 
		await ready
	
	sprite_2d.texture = stats.art
	sprite_2d.scale = Vector2(0.05,0.05)
	arrow.position = Vector2.RIGHT * (sprite_2d.get_rect().size.x / 2 + ARROW_OFFSET)
	setup_ai()
	update_stats()


func update_intent() -> void:
	if current_action:
		current_action.update_intent_text()
		intent_ui.update_intent(current_action.intent)


func do_turn() -> void:
	stats.block = 0
	
	if not current_action:
		return
	
	current_action.perform_action()


func take_damage(damage: int, which_modifier: Modifier.Type) -> void:
	if stats.health <= 0:
		return
	
	sprite_2d.material = WHITE_SPRITE_MATERIAL
	var modified_damage := modifier_handler.get_modified_value(damage, which_modifier)
	
	var tween := create_tween()
	tween.tween_callback(Shaker.shake.bind(self, 16, 0.15))
	tween.tween_callback(stats.take_damage.bind(modified_damage))
	tween.tween_interval(0.17)

	tween.finished.connect(
		func():
			sprite_2d.material = null
			
			if stats.health <= 0:
				Events.enemy_died.emit(self)
				queue_free()
	)


func _on_area_entered(_area: Area2D) -> void:
	arrow.show()


func _on_area_exited(_area: Area2D) -> void:
	arrow.hide()
