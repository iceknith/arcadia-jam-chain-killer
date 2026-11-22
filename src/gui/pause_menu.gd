extends Control

func _ready() -> void:
	%SensitivitySlider.value = Globals.sensitivity

func _on_sensitivity_changed(value: float) -> void:
	Globals.sensitivity = value

func _on_restart() -> void:
	Globals.restart.emit()

func _on_exit() -> void:
	get_tree().quit()
