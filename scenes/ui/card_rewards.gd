class_name CardRewards
extends ColorRect

#hamdles card rewards

# signal which card we picked
signal card_reward_selected(card: Card)

const CARD_MENU_UI = preload("res://scenes/ui/card_menu_ui.tscn")

@export var rewards: Array[Card] : set = set_rewards
@export var cards_amount: int = 2

@onready var cards: HBoxContainer = %Cards
@onready var skip_card_reward: Button = %SkipCardReward
@onready var tooltip_popup: Control = %TooltipPopup
@onready var tooltip_card: CenterContainer = %TooltipCard
@onready var card_description: RichTextLabel = %CardDescription
@onready var take_button: Button = %TakeButton

#stores selected card
var selected_card: Card

# This function is called when the node is ready. It clears the rewards and hides the tooltip.
func _ready() -> void:
	_clear_rewards()
	_hide_tooltip()
	
	take_button.pressed.connect(
		func():
				card_reward_selected.emit(selected_card)
				print("drafted %s" % selected_card.id)
				hide()  # hides the screen since we already picked the card #edited
				#queue_free()  # deletes the screen since we already picked the card	#deletes the screen since we already picked the card, need to implement while loop before so i can pick multiple cards
				_hide_tooltip()
	)
	
	skip_card_reward.pressed.connect(
		func(): 
			card_reward_selected.emit(null)
			queue_free()
	)

# This function handles the input events. If the "ui_cancel" action is pressed, it hides the tooltip.
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_hide_tooltip()

# This function clears the rewards by freeing all the card nodes in the cards and tooltip_card containers.

func _clear_rewards() -> void:
	for card: Node in cards.get_children():
		card.queue_free()
		
	for card: Node in tooltip_card.get_children():
		card.queue_free()
		
	selected_card = null

# This function sets the rewards with the new cards passed as argument.
func set_rewards(new_cards: Array[Card]) -> void:
	rewards = new_cards
	
	if not is_node_ready():
		await ready
		
	_clear_rewards()
	for card: Card in rewards:
		var new_card := CARD_MENU_UI.instantiate() as CardMenuUI
		cards.add_child(new_card)
		new_card.card = card
		new_card.tooltip_requested.connect(_show_tooltip)

# This function shows the tooltip for the selected card.
func _show_tooltip(card: Card) -> void:
	selected_card = card
	
	var new_card := CARD_MENU_UI.instantiate() as CardMenuUI
	tooltip_card.add_child(new_card)
	new_card.card = card
	new_card.tooltip_requested.connect(_hide_tooltip.unbind(1))
	card_description.text = card.get_default_tooltip()
	
	tooltip_popup.show()

# This function hides the tooltip if it's visible.
func _hide_tooltip() -> void:
	if not tooltip_popup.visible:
		return

	selected_card = null

	for card: Node in tooltip_card.get_children():
		card.queue_free()
	
	tooltip_popup.hide()

# This function handles the gui input for the tooltip popup. If the "left_mouse" action is pressed, it hides the tooltip.
func _on_tooltip_popup_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse"):
		_hide_tooltip()
