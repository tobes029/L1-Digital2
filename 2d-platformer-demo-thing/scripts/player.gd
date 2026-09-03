extends CharacterBody2D

signal health_changed(current_health)
signal player_died

@export var speed: float = 200.0
@export var max_health: int = 100
@export var death_screen_scene: PackedScene

# Exact distance in pixels the axe should sit from the player's center
@export var axe_distance: float = 24.0 

@onready var health: int = max_health
@onready var axe_hitbox_shape = $Pivot/AxeHitbox/CollisionShape2D if has_node("Pivot/AxeHitbox/CollisionShape2D") else null
@onready var axe_hitbox: Area2D = $Pivot/AxeHitbox if has_node("Pivot/AxeHitbox") else null
@onready var hurtbox: Area2D = $Hurtbox if has_node("Hurtbox") else null
@onready var pivot: Node2D = $Pivot if has_node("Pivot") else null

# Node reference for AnimatedSprite2D
@onready var anim_sprite: AnimatedSprite2D = $Pivot/AnimatedSprite2D if has_node("Pivot/AnimatedSprite2D") else null

# UI References
var health_bar: ProgressBar = null
var portrait: TextureRect = null

# Face sprites
var face_full = preload("res://sprites/full_health.png")
var face_half = preload("res://sprites/half_health.png")
var face_low = preload("res://sprites/low_health.png")

# State variables
var last_direction: Vector2 = Vector2.DOWN
var is_attacking: bool = false

func _ready() -> void:
	get_tree().debug_collisions_hint = true
	
	# Render player above ground tiles (Z = 0)
	z_index = 2

	if axe_hitbox_shape:
		axe_hitbox_shape.disabled = true

	if has_node("HUD/PlayerHealthBar"):
		health_bar = $HUD/PlayerHealthBar
		
	if has_node("HUD/Portrait"):
		portrait = $HUD/Portrait

	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health
	
	_update_portrait()
	
	if hurtbox:
		hurtbox.area_entered.connect(_on_hurtbox_area_entered)

func _physics_process(_delta: float) -> void:
	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
	move_and_slide()
	
	if direction != Vector2.ZERO:
		last_direction = direction
		update_animation(direction, true)
	else:
		update_animation(last_direction, false)

	if Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("ui_accept"):
		attack()

func update_animation(dir: Vector2, is_moving: bool) -> void:
	if not anim_sprite:
		return

	if pivot:
		pivot.scale = Vector2.ONE

	# Determines whether to call "walk_..." or "idle_..."
	var anim_prefix = "walk_" if is_moving else "idle_"
	var anim_to_play = ""

	if abs(dir.x) > abs(dir.y):
		# Horizontal direction
		if dir.x > 0:
			anim_to_play = anim_prefix + "right"
			if axe_hitbox:
				axe_hitbox.scale = Vector2.ONE
				axe_hitbox.position = Vector2(axe_distance, 0)
				axe_hitbox.z_index = 0
		else:
			anim_to_play = anim_prefix + "left"
			if axe_hitbox:
				axe_hitbox.scale = Vector2(-1, 1)
				axe_hitbox.position = Vector2(-axe_distance, 0)
				axe_hitbox.z_index = 0
	else:
		# Vertical direction
		if axe_hitbox:
			axe_hitbox.scale = Vector2.ONE
			axe_hitbox.position = Vector2(0, 0)

		if dir.y > 0:
			anim_to_play = anim_prefix + "back"
			if axe_hitbox: axe_hitbox.z_index = 1
		else:
			anim_to_play = anim_prefix + "front"
			if axe_hitbox: axe_hitbox.z_index = -1

	# Safe play call: only attempts to play if the animation exists
	if anim_sprite.sprite_frames and anim_sprite.sprite_frames.has_animation(anim_to_play):
		anim_sprite.play(anim_to_play)
	elif anim_sprite.sprite_frames and anim_sprite.sprite_frames.has_animation("default"):
		anim_sprite.play("default")

func attack() -> void:
	if is_attacking:
		return

	is_attacking = true

	if axe_hitbox_shape:
		axe_hitbox_shape.disabled = false
		await get_tree().create_timer(0.2).timeout
		axe_hitbox_shape.disabled = true

	is_attacking = false

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area is Hitbox or "damage" in area:
		var dmg = area.damage if "damage" in area else 10
		take_damage(dmg)

func take_damage(amount: int) -> void:
	health -= amount
	health_changed.emit(health)
	
	if health_bar:
		health_bar.value = health
		
	_update_portrait()
	
	if health <= 0:
		die()

func _update_portrait() -> void:
	if not portrait:
		return
		
	var health_percent: float = float(health) / float(max_health)
	
	if health_percent > 0.6:
		portrait.texture = face_full
	elif health_percent > 0.25:
		portrait.texture = face_half
	else:
		portrait.texture = face_low

func die() -> void:
	player_died.emit()
	get_tree().change_scene_to_file("res://scenes/death_screen.tscn")
