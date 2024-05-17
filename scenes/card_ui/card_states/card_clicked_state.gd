extends CardState


func enter() -> void:
	print("card clicked entered")

	card_ui.drop_point_detector.monitoring = true
	card_ui.original_index = card_ui.get_index()
	#edited, tooltip verschwindet bei allen states ausser base

	Events.tooltip_hide_requested.emit()



func on_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		transition_requested.emit(self, CardState.State.DRAGGING)
		#edited
