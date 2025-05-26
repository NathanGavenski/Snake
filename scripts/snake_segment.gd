extends CharacterBody2D

var previous: CharacterBody2D = null
var next: CharacterBody2D = null
var head: bool = false
var tail: bool = false
var grid_position: Vector2

func revert() -> void:
	var old = self.previous
	self.previous = self.next
	self.next = old

func move() -> void:
	self.position = self.previous.position
	self.grid_position = self.previous.grid_position

func move_head(direction: Vector2, cell_size: int, offset: Vector2) -> void:
	if self.head:
		self.grid_position += direction
		self.position = (self.grid_position * cell_size) + Vector2(0, cell_size)
		self.position += offset

func set_head() -> void:
	self.head = true
	self.tail = false

func set_tail() -> void:
	self.tail = true
	self.head = false

func get_direction() -> Vector2:
	return self.previous.grid_position - self.grid_position
