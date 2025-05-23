extends Node

@export var snake_scene: PackedScene
@export var apple_scene: PackedScene

var score: int
var game_started: bool = false

var cells: int = 20
var cell_size: int = 50

var old_data: Array
var snake_data: Array
var snake: Array
var snake_offset: Vector2

var start_pos = Vector2(9, 9)
var up = Vector2(0, -1)
var down = Vector2(0, 1)
var left = Vector2(-1, 0)
var right = Vector2(1, 0)
var move_direction: Vector2
var can_move: bool = true

var food: Node2D
var apple_offset: Vector2
var food_pos: Vector2
var food_vanish: bool = true
var food_timeout: int = 40
var food_time: int = 0
var animation: Tween

func _ready() -> void:
	self.new_game()

func new_game() -> void:
	if get_tree().paused:
		get_tree().paused = false
		get_tree().call_group("snake", "queue_free")
	$GameOverMenu.hide()
	$MenuLayer.hide()

	self.score = 0
	self.move_direction = self.up
	self.update_score(0)
	self.generate_snake()
	self.spawn_food()

func update_score(new_score: int) -> void:
	self.score = new_score
	$Hud.get_node("ScoreLabel").text = "Score: " + str(new_score)

func generate_snake() -> void:
	self.old_data.clear()
	self.snake_data.clear()
	self.snake.clear()
	
	for i in range(3):
		self.add_segment(self.start_pos + Vector2(0, i))

func add_segment(pos: Vector2) -> void:
	self.snake_data.append(pos)
	var snake_segment = self.snake_scene.instantiate()
	var sprite = snake_segment.get_node("Sprite2D")
	var true_size = sprite.texture.get_size() * sprite.scale
	var center = true_size / 2
	var offset = floor((Vector2(self.cell_size, self.cell_size) - true_size) / 2)
	self.snake_offset = offset + center
	
	snake_segment.position = (pos * self.cell_size) + Vector2(0, self.cell_size)
	snake_segment.position += self.snake_offset

	add_child(snake_segment)
	self.snake.append(snake_segment)

func _process(_delta: float) -> void:
	self.move_snake()

func move_snake() -> void:
	if self.can_move:
		if Input.is_action_just_pressed("move_down") and move_direction != self.up:
			self.move_direction = self.down
			self.can_move = false
			if not self.game_started:
				self.start_game()
		if Input.is_action_just_pressed("move_up") and move_direction != self.down:
			self.move_direction = self.up
			self.can_move = false
			if not self.game_started:
				self.start_game()
		if Input.is_action_just_pressed("move_left") and move_direction != self.right:
			self.move_direction = self.left
			self.can_move = false
			if not self.game_started:
				self.start_game()
		if Input.is_action_just_pressed("move_right") and move_direction != self.left:
			self.move_direction = self.right
			self.can_move = false
			if not self.game_started:
				self.start_game()

func start_game() -> void:
	self.game_started = true
	$MoveTimer.start()
	self.tick_food()

func finish_game() -> bool:
	var out_of_bound = self.check_out_of_bounds()
	var eaten = self.check_self_eaten()
	return out_of_bound or eaten

func check_out_of_bounds() -> bool:
	if not $MenuLayer.borderless:
		var _down = self.snake_data[0].x < 0
		var _up = self.snake_data[0].x > self.cells - 1
		var _left = self.snake_data[0].y < 0
		var _right = self.snake_data[0].y > self.cells - 1
		return _down or _up or _left or _right
	return false

func check_self_eaten() -> bool:
	for i in range(1, len(self.snake_data)):
		if self.snake_data[0] == self.snake_data[i]:
			return true
	return false

func end_game() -> void:
	$GameOverMenu.show()
	$MoveTimer.stop()
	self.game_started = false
	get_tree().paused = true

func spawn_food() -> void:
	if not self.food:
		# Create scene
		self.food = self.apple_scene.instantiate()
		
		# Compute offset
		var sprite = self.food.get_node("Sprite2D")
		var true_size = sprite.texture.get_size() * sprite.scale
		var center = true_size / 2
		var offset = floor((Vector2(self.cell_size, self.cell_size) - true_size) / 2)
		self.apple_offset = offset + center
		
		# Set signals
		self.food.body_entered.connect(self.check_food_eaten)
		add_child(self.food)
	self.move_food()
	
func move_food() -> void:
	self.food.modulate.a = 0
	var _food_pos = Vector2(randi_range(0, self.cells - 1), randi_range(0, self.cells - 1))
	for i in self.snake_data:
		if _food_pos == i:
			return self.move_food()

	if _food_pos == self.food_pos:
		return self.move_food()

	if $MenuLayer.get_different_apples() :
		self.food.pick_apple()

	self.food.position = (_food_pos * self.cell_size) + Vector2(0, self.cell_size)
	self.food.position += self.apple_offset
	self.food_pos = _food_pos

	self.food_time = 0
	self.food.modulate.a = 1

func check_food_eaten(body: Node2D) -> bool:
	if body.is_in_group("snake"):
		if $MenuLayer.get_different_apples():
			if self.food.current_apple == self.food.apple_type.GOOD_APPLE:
				self.update_score(self.score + 1)
			elif self.food.current_apple == self.food.apple_type.BAD_APPLE:
				self.add_segment(self.old_data[-1])
			else:
				self.update_score(self.score + 1)
				self.add_segment(self.old_data[-1])
		else:
			self.update_score(self.score + 1)
			self.add_segment(self.old_data[-1])

		self.move_food()
		return true
	return false

func sigmoid(x: float, steepness: int = 10) -> float:
	var x_norm = (x - 0) / (self.food_timeout - 0)
	var sig = 1 / (1 + exp(-steepness * (x_norm - 0.5)))
	return sig

func tick_food() -> void:
	if self.food_time == self.food_timeout:
		return self.move_food()

	var alpha = 1 - self.sigmoid(self.food_time)
	self.food.modulate.a = alpha
	self.food_time += 1

func _on_move_timer_timeout() -> void:
	can_move = true
	self.old_data = [] + self.snake_data
	self.snake_data[0] += self.move_direction
	
	if $MenuLayer.borderless:
		if self.snake_data[0].x < 0:
			self.snake_data[0].x = self.cells - 1
		elif self.snake_data[0].x >= self.cells:
			self.snake_data[0].x = 0 
		
		if self.snake_data[0].y < 0:
			self.snake_data[0].y = self.cells - 1
		elif self.snake_data[0].y >= self.cells:
			self.snake_data[0].y = 0 
		
	for i in range(len(self.snake_data)):
		if i > 0:
			self.snake_data[i] = self.old_data[i - 1]
		self.snake[i].position = (self.snake_data[i] * self.cell_size) + Vector2(0, self.cell_size)
		self.snake[i].position += self.snake_offset

	if self.finish_game():
		self.end_game()

	if $MenuLayer.food_status:
		self.tick_food()
	elif self.food_time > 0:
		self.food_time = 0
		self.food.modulate.a = 1

func _on_game_over_menu_restart() -> void:
	new_game()

func _on_hud_open_menu() -> void:
	$MenuLayer.show()
	$MoveTimer.stop()
	get_tree().paused = true

func _on_menu_layer_menu_exit() -> void:
	$MenuLayer.hide()
	self.game_started = false
	new_game()
