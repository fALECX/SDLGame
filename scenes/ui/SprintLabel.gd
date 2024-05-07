extends HBoxContainer

@export var label_icon: Texture : set = set_label_icon
@export var label_text: String : set = set_label_text
#
@onready var custom_icon: TextureRect = %CustomIcon
@onready var custom_text: Label = %CustomText

@export var run_stats: RunStats
@export var map: Map


@onready var SprintLabel: HBoxContainer = %SprintLabel

func _ready() -> void:

	$".".text = "Sprint 123"
	#run_stats = RunStats.new()
	#run_stats.sprint_changed.connect(func(): print("Sprint changed to: ", map.sprint_changed))

func set_label_icon(new_icon: Texture) -> void:
	label_icon = new_icon

	if not is_node_ready():
		await ready

	custom_icon.texture = label_icon

func set_label_text(new_text: String) -> void:
	label_text = new_text

	if not is_node_ready():
		await ready

	#custom_text.text = label_text

