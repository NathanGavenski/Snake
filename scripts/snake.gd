extends Node

var segment: PackedScene = preload("res://scenes/snake_segment.tscn")

var old_data: Array
var segments: Array

var can_move: bool = true
var snake_offset: Vector2
var cell_size: int
var cells: int

func _ready() -> void:
	pass

func generate_snake(start_pos: Vector2, _cell_size: int, _cells: int) -> void:
	self.old_data.clear()
	self.segments.clear()
	self.cell_size = _cell_size
	self.cells = _cells
	
	for i in range(3):
		self.add_segment(start_pos + Vector2(0, i))
	
	self.segments[0].head = true
	self.segments[-1].tail = true

func add_segment(pos: Vector2) -> void:
	var snake_segment = self.segment.instantiate()
	var sprite = snake_segment.get_node("Sprite2D")
	var true_size = sprite.texture.get_size() * sprite.scale
	var center = true_size / 2
	var offset = floor((Vector2(self.cell_size, self.cell_size) - true_size) / 2)
	self.snake_offset = offset + center
	
	snake_segment.position = (pos * self.cell_size) + Vector2(0, self.cell_size)
	snake_segment.position += self.snake_offset
	snake_segment.grid_position = pos

	call_deferred("add_child", snake_segment)
	self.segments.append(snake_segment)

	if len(self.segments) > 1:
		var index = len(self.segments) - 1
		self.segments[index - 1].tail = false
		self.segments[index - 1].next = snake_segment
		self.segments[index].previous = self.segments[index - 1]

func move(direction: Vector2, borderless: bool) -> void:
	self.can_move = true

	for i in range(len(self.segments) - 1, 0, -1):
		self.segments[i].move()
	self.segments[0].move_head(direction, self.cell_size, self.snake_offset)

	if borderless:
		if self.segments[0].grid_position.x < 0:
			self.segments[0].grid_position.x = self.cells
		elif self.segments[0].grid_position.x == self.cells:
			self.segments[0].grid_position.x = -1

		if self.segments[0].grid_position.y < 0:
			self.segments[0].grid_position.y = self.cells
		elif self.segments[0].grid_position.y == self.cells:
			self.segments[0].grid_position.y = -1

func check_self_eaten() -> bool:
	for i in range(1, len(self.segments)):
		if self.segments[0].grid_position == self.segments[i].grid_position:
			return true
	return false

func revert() -> void:
	self.segments.reverse()
	for single_segment in self.segments:
		single_segment.revert()
	self.segments[0].set_head()
	self.segments[-1].set_tail()
