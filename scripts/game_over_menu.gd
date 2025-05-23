extends CanvasLayer

signal restart

func _on_restart_button_pressed() -> void:
	self.restart.emit()
