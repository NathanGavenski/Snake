extends CanvasLayer

signal menu_exit
signal restart

var food_status: bool = false
var borderless: bool = false
var different_apples: bool = true

func _on_check_button_toggled(toggled_on: bool) -> void:
	self.food_status = toggled_on

func _on_border_button_toggled(toggled_on: bool) -> void:
	self.borderless = toggled_on

func _on_exit_button_pressed() -> void:
	self.menu_exit.emit()

func get_different_apples() -> bool:
	return self.food_status and self.different_apples
