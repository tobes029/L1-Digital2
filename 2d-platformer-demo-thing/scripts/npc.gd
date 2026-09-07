extends Area2D

@onready var ui_tip: Label = $UITip
@onready var chat_box: Panel = $CanvasLayer/ChatBox
@onready var dialogue_text: Label = $CanvasLayer/ChatBox/DialogueText

@export var dialogue_lines: Array[String] = [
	"Why, hello there!", 
	"I'm Jameroquai... NOT like the acid jazz group.", 
	"Do you even know what the point of you being here is?", 
	"Me neither.... best not to ask too many questions...", 
	"You can press the space bar to attack. \nThere's all sorts of bad guys around here.",
	"Tread carefully! \nMy cousin Domingo is around here somewhere... \nHe might be of some help."
]
@export var typing_speed: float = 0.04

var player_in_range: bool = false
var current_line: int = 0
var is_typing: bool = false
var typing_tween: Tween

func _ready() -> void:
	# Hide dialogue elements on game load
	if ui_tip:
		ui_tip.hide()
	if chat_box:
		chat_box.hide()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") or body.name == "Player":
		player_in_range = true
		if chat_box and not chat_box.visible: 
			if ui_tip:
				ui_tip.show()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player") or body.name == "Player":
		player_in_range = false
		if ui_tip:
			ui_tip.hide()
		if chat_box:
			chat_box.hide()
		is_typing = false

func _input(event: InputEvent) -> void:
	if not player_in_range:
		return

	var talk_pressed = event.is_action_pressed("talk") or (event is InputEventKey and event.pressed and event.keycode == KEY_E)

	if talk_pressed:
		get_viewport().set_input_as_handled()

		if chat_box and not chat_box.visible:
			if ui_tip:
				ui_tip.hide()
			
			# Open the chat box
			chat_box.show()
			current_line = 0
			show_line()
		elif is_typing:
			# Skip typewriter typing animation
			finish_typing()
		else:
			# Next dialogue line
			current_line += 1
			if current_line < dialogue_lines.size():
				show_line()
			else:
				# End of dialogue
				if chat_box:
					chat_box.hide()
				if ui_tip:
					ui_tip.show()

func show_line() -> void:
	if not dialogue_text or not chat_box:
		print("Error: Missing ChatBox or DialogueText reference!")
		return

	# Ensure panel and text are fully visible
	chat_box.show()
	dialogue_text.show()
	dialogue_text.text = dialogue_lines[current_line]
	dialogue_text.visible_characters = -1
	dialogue_text.visible_ratio = 0.0
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

	if dialogue_text:
		dialogue_text.visible_ratio = 1.0
	is_typing = false
