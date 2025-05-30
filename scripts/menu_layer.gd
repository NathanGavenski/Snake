extends CanvasLayer

signal menu_exit

var food_status: bool = false
var different_apples: bool = false
var borderless: bool = false
var portal: bool = true

var off_alpha: float = 0.7
var on_alpha: float = 1.

func _ready() -> void:
	$Panel/ApplesButton.set("disabled", not self.food_status)
	$Panel/ApplesLabel.modulate.a = self.off_alpha
	
	if self.food_status:
		$Panel/FoodButton.set("button_pressed", true)
	if self.different_apples:
		$Panel/ApplesButton.set("button_pressed", true)
	if self.borderless:
		$Panel/BorderButton.set("button_pressed", true)
	if self.portal:
		$Panel/PortalButton.set("button_pressed", true)

func _on_check_button_toggled(toggled_on: bool) -> void:
	self.food_status = toggled_on
	$Panel/ApplesButton.set("disabled", not self.food_status)
	$Panel/ApplesLabel.modulate.a = self.on_alpha if toggled_on else self.off_alpha
	if toggled_on:
		$Panel/ApplesLabel.modulate.a = self.on_alpha

func _on_border_button_toggled(toggled_on: bool) -> void:
	self.borderless = toggled_on

func _on_apples_button_toggled(toggled_on: bool) -> void:
	if self.food_status:
		self.different_apples = toggled_on

func _on_portal_button_toggled(toggled_on: bool) -> void:
	self.portal = toggled_on

func _on_exit_button_pressed() -> void:
	self.menu_exit.emit()

func get_different_apples() -> bool:
	return self.food_status and self.different_apples
