extends Node

signal restart
signal settingsToggle
signal gameEnd
signal sensitivity_change(new_value:float)
signal startBossFight

@export var sensitivity = 75 :
	set(new_sensitivity):
		sensitivity_change.emit(new_sensitivity)
		sensitivity = new_sensitivity

var enemies_killed:int = 0
var damage_taken:float = 0
var death:float = 0
var time:float = 0

func score() -> String:
	if (_is_SSS_score()):
		return 'SSS'
	if (_is_S_score()):
		return 'S'
	elif (_is_A_score()):
		return 'A'
	elif (_is_B_score()):
		return 'B'
	elif (_is_C_score()):
		return 'C'
	elif (_is_D_score()):
		return 'D'
	elif (_is_E_score()):
		return 'E'
	else:
		return 'F'

func _is_SSS_score() -> bool:
	return damage_taken < 10 && death <= 0 && time <= 90 && enemies_killed >= 5

func _is_S_score() -> bool:
	return damage_taken < 10 && death <= 0 && time <= 180 && enemies_killed >= 20

func _is_A_score() -> bool:
	return damage_taken < 50 && death <= 1 && time <= 320 && enemies_killed >= 16

func _is_B_score() -> bool:
	return damage_taken < 200 && death <= 4 && time <= 480 && enemies_killed >= 13

func _is_C_score() -> bool:
	return damage_taken < 500 && death <= 10 && time <= 660 && enemies_killed >= 10

func _is_D_score() -> bool:
	return damage_taken < 1000 && death <= 15 && time <= 860 && enemies_killed >= 8

func _is_E_score() -> bool:
	return damage_taken < 2000 && death <= 20 && time <= 1200 && enemies_killed >= 5
