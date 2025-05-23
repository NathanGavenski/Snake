extends Area2D

enum apple_type {APPLE, GOOD_APPLE, BAD_APPLE, REVERSE_APPLE}

var apple = preload("res://assets/apples/RedApple.png")
var good_apple = preload("res://assets/apples/GoldenApple.png")
var bad_apple = preload("res://assets/apples/DirtApple.png")
var reverse_apple = preload("res://assets/apples/MagentaApple.png")

var current_apple: int

func _ready() -> void:
	$Sprite2D.texture = self.apple
	self.current_apple = self.apple_type.APPLE

func pick_apple() -> void:
	var odds = randi_range(0, 100)
	if odds >= 85 and odds < 95:
		$Sprite2D.texture = self.bad_apple
		self.current_apple = self.apple_type.BAD_APPLE
	elif odds >= 95:
		$Sprite2D.texture = self.good_apple
		self.current_apple = self.apple_type.GOOD_APPLE
	else:
		$Sprite2D.texture = self.apple
		self.current_apple = self.apple_type.APPLE
