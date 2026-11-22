extends Node

signal restart
signal settingsToggle
signal gameEnd
signal sensitivity_change(new_value:float)

@export var sensitivity = 75 :
	set(new_sensitivity):
		sensitivity_change.emit(new_sensitivity)
		sensitivity = new_sensitivity

var enemies_killed:int = 0
var damage_taken:float = 0
var death:float = 0
var time:float = 0

func score() -> String:
	if (_is_S_score()):
		return 'S'
	else:
		return 'F'

func _is_S_score() -> bool:
	return damage_taken < 10 && death <= 0 && time <= 60 && enemies_killed >= 30
