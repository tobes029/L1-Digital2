extends Area2D

@onready var ui_tip: Label = $UITip
@onready var chat_box: Panel = $CanvasLayer/ChatBox
@onready var dialogue_text: Label = $CanvasLayer/ChatBox/DialogueText

@export var dialogue_lines: Array[String] = [
	"Why, hello there!", 
	"I'm Jameroquai... NOT like the acid jazz group.", 
	"Do you even know what the point of you being here is?", 
	"Me neither.... best not to ask too many questions...", 
	"You can press the space bar to attack. /n theres all sorts of bad guys around here",
	"Tread carefully! /n My cousin Domingo is around here somewhere... /n He might be of some help."
]
@export var typing_speed: float = 0.04

var player_in_range: bool = false
var current_line: int = 0
var is_typing: bool = false
var typing_tween: Tween

func _ready() -> void:
	ui_tip.hide()
	chat_box.hide()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = true
		if not chat_box.visible: 
			ui_tip.show()

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = false
		ui_tip.hide()
		chat_box.hide()
		is_typing = false

func _input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("ui_down"):
		if not chat_box.visible:
			ui_tip.hide()
			chat_box.show()
			current_line = 0
			show_line()
		elif is_typing:
			finish_typing()
		else:
			current_line += 1
			if current_line < dialogue_lines.size():
				show_line()
			else:
				chat_box.hide()
				ui_tip.show()

func show_line() -> void:
	dialogue_text.text = dialogue_lines[current_line]
	dialogue_text.visible_characters = -1 # (-1 means "show all")
	dialogue_text.visible_ratio = 0.0 # Start at 0% visible
	is_typing = true

	if typing_tween and typing_tween.is_valid():
		typing_tween.kill()

	typing_tween = create_tween()
	var duration = dialogue_lines[current_line].length() * typing_speed

	typing_tween.tween_property(dialogue_text, "visible_ratio", 1.0, duration)
	typing_tween.finished.connect(func(): is_typing = false)

func finish_typing() -> void:
	if typing_tween and typing_tween.is_valid():
		typing_tween.kill()

	dialogue_text.visible_ratio = 1.0 # Instantly show 100% of the text
	is_typing = false
