extends Node

@export var apple_scene: PackedScene
@export var snake_scene: PackedScene
@export var portal_scene: PackedScene

var score: int
var game_started: bool = false

var cells: int = 20
var cell_size: int = 50

var up = Vector2(0, -1)
var down = Vector2(0, 1)
var left = Vector2(-1, 0)
var right = Vector2(1, 0)
var reverse_direction = {self.up: self.down, self.down: self.up, self.left: self.right, self.right: self.left}
var move_direction: Vector2 = Vector2(0, 0)

var snake: Node2D
var start_pos = Vector2(9, 9)
var food: Node2D
var portals: Array = []

func _ready() -> void:
	self.new_game()

func new_game() -> void:
	if get_tree().paused:
		get_tree().paused = false
		
		get_tree().call_group("snake", "queue_free")

		self.portals.clear()
		get_tree().call_group("portal", "queue_free")
	$GameOverMenu.hide()
	$MenuLayer.hide()

	self.score = 0
	self.move_direction = self.up
	self.update_score(0)
	self.spawn_snake()
	self.spawn_food()
	
	if $MenuLayer.portal:
		self.spawn_portal()

# GAME CODE
func update_score(new_score: int) -> void:
	self.score = new_score
	$Hud.get_node("ScoreLabel").text = "Score: " + str(new_score)

func end_game() -> void:
	$GameOverMenu.show()
	$MoveTimer.stop()
	self.game_started = false
	get_tree().paused = true

# SNAKE CODE
func spawn_snake() -> void:
	self.snake = self.snake_scene.instantiate()
	self.snake.generate_snake(self.start_pos, self.cell_size, self.cells)
	add_child(snake)

func move_snake() -> void:
	if self.snake.can_move:
		if Input.is_action_just_pressed("move_down") and move_direction != self.up:
			self.move_direction = self.down
			self.snake.can_move = false
			if not self.game_started:
				self.start_game()
		if Input.is_action_just_pressed("move_up") and move_direction != self.down:
			self.move_direction = self.up
			self.snake.can_move = false
			if not self.game_started:
				self.start_game()
		if Input.is_action_just_pressed("move_left") and move_direction != self.right:
			self.move_direction = self.left
			self.snake.can_move = false
			if not self.game_started:
				self.start_game()
		if Input.is_action_just_pressed("move_right") and move_direction != self.left:
			self.move_direction = self.right
			self.snake.can_move = false
			if not self.game_started:
				self.start_game()

func start_game() -> void:
	self.game_started = true
	$MoveTimer.start()
	self.tick_food()

func finish_game() -> bool:
	var out_of_bound = self.check_out_of_bounds()
	var eaten = self.snake.check_self_eaten()
	return out_of_bound or eaten

func check_out_of_bounds() -> bool:
	if not $MenuLayer.borderless:
		var _down = self.snake.segments[0].grid_position.x < 0
		var _up = self.snake.segments[0].grid_position.x  > self.cells - 1
		var _left = self.snake.segments[0].grid_position.y < 0
		var _right = self.snake.segments[0].grid_position.y > self.cells - 1
		return _down or _up or _left or _right
	return false

# PORTAL CODE
func spawn_portal() -> void:
	if not self.portals:
		var in_portal: Area2D = self.portal_scene.instantiate()
		var out_portal: Area2D = self.portal_scene.instantiate()
		self.portals.append_array([in_portal, out_portal])
		
		in_portal.set_in_portal()
		out_portal.set_out_portal()
		
		var sprite: Sprite2D = in_portal.get_node("Sprite2D")
		var true_size = sprite.texture.get_size() * sprite.scale
		var center = true_size / 2
		var offset = floor((Vector2(self.cell_size, self.cell_size) - true_size) / 2)
		in_portal.offset = offset + center
		out_portal.offset = offset + center
		
		in_portal.body_entered.connect(self.teleport_in)
		out_portal.body_entered.connect(self.teleport_out)
		add_child(in_portal)
		add_child(out_portal)
		self.move_portals()

func teleport_in(body: Node2D) -> void:
	if body.is_in_group("snake") and body.head:
		self.teleport(body, self.portals[1])

func teleport_out(body: Node2D) -> void:
	if body.is_in_group("snake") and body.head:
		self.teleport(body, self.portals[0])

func teleport(body: Node2D, destination: Area2D) -> void:
	body.grid_position = destination.grid_position

func move_portals() -> void:
	for portal in self.portals:
		var portal_set = false
		while not portal_set:
			portal.modulate.a = 0
			var _pos = Vector2(randi_range(0, self.cells - 1), randi_range(0, self.cells - 1))
			
			for segments in self.snake.segments:
				if _pos == segments.grid_position:
					continue
			
			for _portal in self.portals:
				if _pos == _portal.grid_position:
					continue
			
			if self.food:
				if _pos == self.food.grid_position:
					continue
			
			portal.position = (_pos * self.cell_size) + Vector2(0, self.cell_size)
			portal.position += portal.offset
			portal.grid_position = _pos
			portal_set = true
			portal.time_alive = 0
			portal.modulate.a = 1

func tick_portal() -> void:
	for portal in self.portals:
		if portal.lifespan == portal.time_alive:
			return self.move_portals()
	
		var alpha = 1 - self.sigmoid(portal.time_alive, portal.lifespan)
		portal.modulate.a = alpha
		portal.time_alive += 1

# FOOD CODE
func spawn_food() -> void:
	if not self.food:
		# Create scene
		self.food = self.apple_scene.instantiate()
		
		# Compute offset
		var sprite: Sprite2D = self.food.get_node("Sprite2D")
		var true_size = sprite.texture.get_size() * sprite.scale
		var center = true_size / 2
		var offset = floor((Vector2(self.cell_size, self.cell_size) - true_size) / 2)
		self.food.offset = offset + center
		
		# Set signals
		self.food.body_entered.connect(self.check_food_eaten)
		add_child(self.food)
	self.move_food()

func check_food_eaten(body: Node2D) -> bool:
	if body.is_in_group("snake"):
		if $MenuLayer.get_different_apples():
			if self.food.current_apple == self.food.apple_type.GOOD_APPLE:
				self.update_score(self.score + 1)
			elif self.food.current_apple == self.food.apple_type.BAD_APPLE:
				self.snake.add_segment(self.snake.segments[-1].grid_position)
			elif self.food.current_apple == self.food.apple_type.REVERSE_APPLE:
				self.update_score(self.score + 1)
				var direction = self.reverse_direction[self.snake.segments[-1].get_direction()]
				self.snake.add_segment(self.snake.segments[-1].grid_position)
				self.snake.revert()
				self.move_direction = direction
			else:
				self.update_score(self.score + 1)
				self.snake.add_segment(self.snake.segments[-1].grid_position)
		else:
			self.update_score(self.score + 1)
			self.snake.add_segment(self.snake.segments[-1].grid_position)

		self.move_food()
		return true
	return false

func move_food() -> void:
	self.food.modulate.a = 0
	var _food_pos = Vector2(randi_range(0, self.cells - 1), randi_range(0, self.cells - 1))
	for segments in self.snake.segments:
		if _food_pos == segments.grid_position:
			return self.move_food()

	if _food_pos == self.food.grid_position:
		return self.move_food()

	if $MenuLayer.get_different_apples() :
		self.food.pick_apple()

	self.food.position = (_food_pos * self.cell_size) + Vector2(0, self.cell_size)
	self.food.position += self.food.offset
	self.food.grid_position = _food_pos

	self.food.time_alive = 0
	self.food.modulate.a = 1

func tick_food() -> void:
	if self.food.time_alive == self.food.lifespan:
		return self.move_food()

	var alpha = 1 - self.sigmoid(self.food.time_alive, self.food.lifespan)
	self.food.modulate.a = alpha
	self.food.time_alive += 1

# SIGNALS
func _on_update_score(new_score: int) -> void:
	self.update_score(new_score)
	self.move_food()

func _on_move_timer_timeout() -> void:
	self.snake.move(self.move_direction, $MenuLayer.borderless)

	if self.finish_game():
		self.end_game()

	if $MenuLayer.food_status:
		self.tick_food()
	elif self.food.time_alive > 0:
		self.food.time_alive = 0
		self.food.modulate.a = 1
	
	if $MenuLayer.portal:
		self.tick_portal()

func _on_game_over_menu_restart() -> void:
	new_game()

func _on_hud_open_menu() -> void:
	$MenuLayer.show()
	$MoveTimer.stop()
	get_tree().paused = true

func _on_menu_layer_menu_exit() -> void:
	$MenuLayer.hide()
	self.game_started = false
	self.new_game()

func _process(_delta: float) -> void:
	self.move_snake()

# UTILS CODE
func sigmoid(x: float, max: int, steepness: int = 10) -> float:
	var x_norm = (x - 0) / (max - 0)
	var sig = 1 / (1 + exp(-steepness * (x_norm - 0.5)))
	return min(sig, 0.95)
