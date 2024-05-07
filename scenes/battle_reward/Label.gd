extends Label

@onready var label: Label = %Text

func _ready() -> void:
    $Label.text = "Hello, World!"