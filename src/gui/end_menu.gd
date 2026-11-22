extends Control

@export var animation_duration:float = 1.0

var damage_taken:int = 0
var enemies_killed:int = 0
var deaths:int = 0
var time:float = 0

func _ready() -> void:
	%Score.text = Globals.score()
	animate()

func animate() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	%Score.modulate = Color.TRANSPARENT
	%ButtonContainer.modulate = Color.TRANSPARENT
	
	if Globals.damage_taken > 0:
		tween.tween_property(self, 'damage_taken', Globals.damage_taken, animation_duration)
	if Globals.damage_taken > 0:
		tween.tween_property(self, 'enemies_killed', Globals.damage_taken, animation_duration)
	if Globals.damage_taken > 0:
		tween.tween_property(self, 'deaths', Globals.damage_taken, animation_duration)
	if Globals.damage_taken > 0:
		tween.tween_property(self, 'time', Globals.damage_taken, animation_duration)
	
	tween.tween_property(%Score, 'modulate', Color.WHITE, animation_duration * 2)
	tween.parallel().tween_property(%ButtonContainer, 'modulate', Color.WHITE, animation_duration * 2)

func _process(delta: float) -> void:
	%DamageTaken.text = str(damage_taken)
	%EnemiesKilled.text = str(enemies_killed)
	%Deaths.text = str(deaths)
	%Time.text = str(int(time))

func _on_restart() -> void:
	Globals.restart.emit()

func _on_exit() -> void:
	get_tree().quit()
