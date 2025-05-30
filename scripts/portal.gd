extends Node2D

var in_potal_sprite = preload("res://assets/portal/in_portal.png")
var out_portal_sprite = preload("res://assets/portal/out_portal.png")

var grid_position: Vector2
var offset: Vector2

var in_portal: bool
var lifespan: int = 30
var time_alive: int = 0

func set_in_portal() -> void:
	self.in_portal = true
	$Sprite2D.texture = self.in_potal_sprite

func set_out_portal() -> void:
	self.in_portal = false
	$Sprite2D.texture = self.out_portal_sprite
