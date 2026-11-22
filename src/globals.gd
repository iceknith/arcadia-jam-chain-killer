extends Node

signal restart
signal sensitivity_change(new_value:float)

@export var sensitivity = 75 :
	set(new_sensitivity):
		sensitivity_change.emit(new_sensitivity)
		sensitivity = new_sensitivity
