extends Area2D

enum apple_type {APPLE, GOOD_APPLE, BAD_APPLE, REVERSE_APPLE}

var apple = preload("res://assets/apples/RedApple.png")
var good_apple = preload("res://assets/apples/GoldenApple.png")
var bad_apple = preload("res://assets/apples/DirtApple.png")
var reverse_apple = preload("res://assets/apples/MagentaApple.png")

var grid_position: Vector2 = Vector2(0, 0)
var current_apple: int
var offset: Vector2 = Vector2(0, 0)

var lifespan: int = 30
var time_alive: int = 0

func _ready() -> void:
	$Sprite2D.texture = self.apple
	self.current_apple = self.apple_type.APPLE

func pick_apple() -> void:
	var odds = randi_range(0, 100)
	if odds >= 82 and odds < 92:
		$Sprite2D.texture = self.bad_apple
		self.current_apple = self.apple_type.BAD_APPLE
	elif odds >= 92 and odds < 98:
		$Sprite2D.texture = self.good_apple
		self.current_apple = self.apple_type.GOOD_APPLE
	elif odds >= 98:
		$Sprite2D.texture = self.reverse_apple
		self.current_apple = self.apple_type.REVERSE_APPLE
	else:
		$Sprite2D.texture = self.apple
		self.current_apple = self.apple_type.APPLE
