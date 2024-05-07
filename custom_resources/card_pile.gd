class_name CardPile
extends Resource

signal card_pile_size_changed(cards_amount: int)

@export var cards: Array[Card] = []

# This function checks if the cards array is empty.
func empty() -> bool:
	return cards.is_empty()

# This function removes the first card from the cards array and returns it.

func draw_card() -> Card:
	var card = cards.pop_front()
	card_pile_size_changed.emit(cards.size())
	return card

# This function adds a card to the cards array.

func add_card(card: Card) -> void:
	cards.append(card)
	card_pile_size_changed.emit(cards.size()) #emitting the signal defined on top and passing the size of the cards array

# This function shuffles the cards array.

func shuffle() -> void:
	RNG.array_shuffle(cards)

# This function clears the cards array.

func clear() -> void:
	cards.clear()
	card_pile_size_changed.emit(cards.size())

# This function converts the cards array to a string.

func _to_string() -> String:
	var _card_strings: PackedStringArray = []
	for i in cards.size():
		_card_strings.append("%s: %s" % [i+1, cards[i].id])
	return "\n".join(_card_strings)
