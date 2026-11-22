extends Control

@export var ANIM_DURATION:float = 0.5
@export var BAR_MG_DEBOUNCE_TIME:float = 1.5

@export var fg_color:Color
@export var mg_color:Color
@export var bg_color:Color
@export var value:float = 1:
	set(new_value):
		value = new_value
		if bar_tween: bar_tween.kill()
		bar_tween = create_tween()
		bar_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		bar_tween.tween_property(self, 'bar_value', new_value, ANIM_DURATION)
		bar_mg_debounce_timer.start()

var bar_value:float = value
var bar_mg_value:float = value
var bar_mg_debounce_timer:Timer

var bar_tween:Tween

func _ready() -> void:
	bar_mg_debounce_timer = Timer.new()
	bar_mg_debounce_timer.one_shot = true
	bar_mg_debounce_timer.wait_time = BAR_MG_DEBOUNCE_TIME
	bar_mg_debounce_timer.timeout.connect(_on_bar_mg_update)
	add_child(bar_mg_debounce_timer)
	
	$FG.color = fg_color
	$MG.color = mg_color
	$BG.color = bg_color

func _on_bar_mg_update():
	if bar_tween: bar_tween.kill()
	bar_tween = create_tween()
	bar_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	bar_tween.tween_property(self, 'bar_mg_value', bar_value, ANIM_DURATION)

func _process(_delta: float) -> void:
	$FG.scale.x = bar_value
	$MG.scale.x = bar_mg_value
