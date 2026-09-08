extends Area2D

@onready var ui_tip: Label = get_node_or_null("%UITip")
@onready var chat_box: Panel = get_node_or_null("%Chatbox")
@onready var dialogue_text: Label = get_node_or_null("%DialogueText")

@export var dialogue_lines: Array[String] = [
	"Whassup, I'm Domingo", 
	"You met my cousin? He's a loser. \nDosen't even own any properties. \nOr investments.", 
	"Do you invest? \nI've got this epic new crypto system", 
	"It feeds profits into the domestic market... \nGets me mad cash \n ..Yo", 
	"But listen amigo, theres big things around here. \nLike a way out.",
	"If you're hurting theres bound to be some chow around \nand maybe even a way out...."
]
@export var typing_speed: float = 0.04

var player_in_range: bool = false
var current_line: int = 0
var is_typing: bool = false
var typing_tween: Tween

func _ready() -> void:
	# Fallback searches
	if not chat_box:
		chat_box = get_node_or_null("CanvasLayer/Chatbox")
	if not dialogue_text:
		dialogue_text = get_node_or_null("CanvasLayer/DialogueText")
		if not dialogue_text:
			dialogue_text = get_node_or_null("CanvasLayer/Chatbox/DialogueText")
	if not ui_tip:
		ui_tip = get_node_or_null("UITip")

	if not chat_box or not dialogue_text:
		print("ERROR: Could not bind Chatbox or DialogueText references.")
		return

	# Hide UI elements on startup
	hide_dialogue_ui()
	if ui_tip:
		ui_tip.hide()

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
		hide_dialogue_ui()
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
			current_line = 0
			show_line()
		elif is_typing:
			finish_typing()
		else:
			current_line += 1
			if current_line < dialogue_lines.size():
				show_line()
			else:
				# End of dialogue lines
				hide_dialogue_ui()
				if ui_tip:
					ui_tip.show()

func show_line() -> void:
	if not dialogue_text or not chat_box:
		return

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

# Helper function to hide panel and clear text simultaneously
func hide_dialogue_ui() -> void:
	if chat_box:
		chat_box.hide()
	if dialogue_text:
		dialogue_text.text = ""
		dialogue_text.hide()
