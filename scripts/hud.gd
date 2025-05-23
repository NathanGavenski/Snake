extends CanvasLayer

signal open_menu

func _on_menu_button_pressed() -> void:
	self.open_menu.emit()
