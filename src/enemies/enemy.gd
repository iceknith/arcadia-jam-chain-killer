class_name Enemy
extends CharacterBody3D

@export var MAX_HEALTH:float = 10

@onready var health = MAX_HEALTH

func damage(damage_delt:float):
	pass

func is_grabbed():
	pass
