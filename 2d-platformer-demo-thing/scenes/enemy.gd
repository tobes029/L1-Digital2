extends CharacterBody2D

signal health_changed(current_health)
signal enemy_died

@export var speed: float = 100.0
@export var max_health: int = 30

@onready var health: int = max_health

var player: CharacterBody2D = null

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	
func _physics_process(_delta: float) -> void:
		if player:
			var direction = global_position.direction_to(player.global_position)
			velocity = direction * speed
			move_and_slide()
			
# hurtbox will seek this
func take_damage(amount: int) -> void:
	health -= amount
	print("Enemy took damage, health left: ", health)
	health_changed.emit(health)
	
	if health <= 0:
		die()
		
func die() -> void:
	enemy_died.emit()
	print("Enemy defeated!")
	queue_free()
