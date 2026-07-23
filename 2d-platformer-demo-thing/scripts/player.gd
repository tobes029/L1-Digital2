extends CharacterBody2D

@export var speed: float = 200.0
@export var health: int = 100

@onready var axe_hitbox_shape = $AxeHitbox/CollisionShape2D

func _physics_process(_delta: float) -> void:
	# movement
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
	move_and_slide()
	
	# attack input 
	if Input.is_action_just_pressed("ui_accept"):
		attack()

func attack() -> void:
	print("Player swings the axe")
	# hitbox shape
	axe_hitbox_shape.disabled = false
	
	# wait before swing
	await get_tree().create_timer(0.2).timeout
	axe_hitbox_shape.disabled = true

func take_damage(amount: int) -> void:
	health -= amount
	print("Player took damage! Health left: ", health)
	if health <= 0:
		die()

func die() -> void:
	print("Player died!")
	queue_free() # removes player
