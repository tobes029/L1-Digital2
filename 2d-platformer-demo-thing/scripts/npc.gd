extends Node2D

@export var npc_name: String = "Villager"
@export_multiline var dialogue_text: String = "Hello traveler! Be careful in the woods."

@onready var interaction_area: Area2D = $InteractionArea

var is_player_in_range: bool = false

func _ready() -> void:
	# Connect Area2D collision signals
	if interaction_area:
		interaction_area.body_entered.connect(_on_interaction_area_body_entered)
		interaction_area.body_exited.connect(_on_interaction_area_body_exited)

func _unhandled_input(event: InputEvent) -> void:
	# Check if player presses the interact button while standing in range
	if is_player_in_range and event.is_action_pressed("interact"):
		interact()

func _on_interaction_area_body_entered(body: Node2D) -> void:
	# Verify that the body entering the area is the Player
	if body.is_in_group("player") or body.name == "Player":
		is_player_in_range = true
		print("Press 'E' to speak with ", npc_name)

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "Player":
		is_player_in_range = false

func interact() -> void:
	print(npc_name, ": ", dialogue_text)
	# Trigger your dialogue box UI or custom NPC logic here!
