extends CharacterBody2D

signal health_changed(current_health)
signal enemy_died

@export var speed: float = 60.0
@export var chase_speed: float = 110.0
@export var max_health: int = 30
@export var attack_damage: int = 10
@export var attack_cooldown: float = 1.5 # Seconds between attacks
@export var score_value: int = 100 # How many points the player earns for defeating this enemy

@onready var health: int = max_health 
@onready var health_bar = $ProgressBar # Health bar UI
@onready var enemy_hitbox_shape = $EnemyHitbox/CollisionShape2D

# Movement variables
var player: CharacterBody2D = null
var wander_direction: Vector2 = Vector2.ZERO
var is_wandering: bool = false
var can_attack: bool = true

func _ready() -> void:
	# Locate the player node in the scene tree using groups
	player = get_tree().get_first_node_in_group("Player")
	
	# Set up the health bar UI initial values
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health
	
	# Starts the timer cycle for random wandering
	_start_wander_timer()

func _physics_process(_delta: float) -> void:
	if player:
		var distance_to_player = global_position.distance_to(player.global_position)
		
		# 1. Close distance attack range
		if distance_to_player <= 30.0:
			velocity = Vector2.ZERO
			if can_attack:
				attack_player()
		
		# 2. Chase state (Medium distance)
		elif distance_to_player < 200.0:
			var direction = global_position.direction_to(player.global_position)
			velocity = direction * chase_speed
		
		# 3. Wander around (Far away)
		else:
			if is_wandering:
				velocity = wander_direction * speed
			else:
				velocity = Vector2.ZERO
	else:
		# If no player exists near, default to wander state
		if is_wandering:
			velocity = wander_direction * speed
		else:
			velocity = Vector2.ZERO
			
	move_and_slide()

# Attack logic
func attack_player() -> void:
	can_attack = false
	print("Enemy attacks the player!")
	
	# Turn on hitbox temporarily
	if enemy_hitbox_shape:
		enemy_hitbox_shape.disabled = false
		await get_tree().create_timer(0.3).timeout # Hitbox active window
		enemy_hitbox_shape.disabled = true
	
	# Wait out the cooldown before striking again
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

# Wander logic
func _start_wander_timer() -> void:
	# Pick a random movement direction
	wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	is_wandering = true
	
	# Move in this direction for 1.5 seconds
	await get_tree().create_timer(1.5).timeout
	
	# Pause for 1 second
	is_wandering = false
	await get_tree().create_timer(1.0).timeout
	
	# Repeat the wander loop if the enemy is still alive
	if is_instance_valid(self):
		_start_wander_timer()

# Health, damage, and defeat logic
func take_damage(amount: int) -> void:
	health -= amount
	print("Enemy took damage, health left: ", health)
	health_changed.emit(health)
	
	# Update the UI bar when taking damage
	if health_bar:
		health_bar.value = health
	
	if health <= 0:
		die()

func die() -> void:
	print("Enemy defeated")
	enemy_died.emit()
	
	# Award score points to the player via the global ScoreManager
	if Engine.has_singleton("ScoreManager") or get_node_or_null("/root/ScoreManager"):
		ScoreManager.add_score(score_value)
		
	queue_free()
