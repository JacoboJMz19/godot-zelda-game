extends CharacterBody2D

# CONFIGURACIÓN

@export var speed: float = 40.0
# Tiempo que permanece escondido
@export var hidden_time: float = 2.0
# Tiempo que permanece visible/moviéndose
@export var visible_time: float = 4.0



# ESTADOS DEL LEEVER

enum State {
	HIDDEN,
	APPEARING,
	MOVING,
	HIDING
}

var current_state: State = State.HIDDEN
# Dirección inicial
var direction: Vector2 = Vector2.RIGHT

# INICIO

func _ready():
	# Comenzar escondido
	hide_leever()

# PROCESO PRINCIPAL

func _physics_process(_delta):
	match current_state:
		State.HIDDEN:
			hidden_state()
		State.APPEARING:
			appearing_state()
		State.MOVING:
			moving_state()
		State.HIDING:
			hiding_state()

# ESTADO: ESCONDIDO

func hidden_state():
	velocity = Vector2.ZERO

# ESCONDER LEEVER

func hide_leever():
	current_state = State.HIDDEN
	velocity = Vector2.ZERO
	# Desactivar colisión
	$CollisionShape2D.disabled = true
	# Ocultar sprite
	$AnimatedSprite2D.visible = false
	# Esperar
	await get_tree().create_timer(hidden_time).timeout
	appear_leever()

# APARECER

func appear_leever():
	current_state = State.APPEARING
	# Mostrar sprite
	$AnimatedSprite2D.visible = true
	# Activar colisión
	$CollisionShape2D.disabled = false
	# Animación de aparición
	if $AnimatedSprite2D.sprite_frames.has_animation("appear"):
		$AnimatedSprite2D.play("appear")
		# Esperar a que termine
		await $AnimatedSprite2D.animation_finished
	else:
		# Si no existe "appear", esperamos un momento
		await get_tree().create_timer(0.2).timeout
	# Elegir dirección inicial
	choose_random_direction()
	# Comenzar movimiento
	current_state = State.MOVING
	update_animation()
	# Tiempo que estará visible
	await get_tree().create_timer(visible_time).timeout
	# Esconderse
	start_hiding()

# ESTADO: APARECIENDO

func appearing_state():
	velocity = Vector2.ZERO

# ESTADO: MOVIMIENTO

func moving_state():
	# Mover Leever
	velocity = direction * speed
	move_and_slide()
	# Revisar paredes
	check_walls()

# REVISAR PAREDES

func check_walls():
	if direction == Vector2.RIGHT:
		if $RayCast2D_RIGHT.is_colliding():
			change_direction()
	elif direction == Vector2.LEFT:
		if $RayCast2D_LEFT.is_colliding():
			change_direction()
	elif direction == Vector2.UP:
		if $RayCast2D_UP.is_colliding():
			change_direction()
	elif direction == Vector2.DOWN:
		if $RayCast2D_DOWN.is_colliding():
			change_direction()

# CAMBIAR DIRECCIÓN

func change_direction():
	var possible_directions = [
		Vector2.UP,
		Vector2.DOWN,
		Vector2.LEFT,
		Vector2.RIGHT
	]
	
	# Mezclar direcciones
	possible_directions.shuffle()
	# Buscar una dirección libre
	for new_direction in possible_directions:
		if can_move(new_direction):
			direction = new_direction
			update_animation()
			return

# COMPROBAR SI PUEDE AVANZAR

func can_move(new_direction: Vector2) -> bool:
	if new_direction == Vector2.UP:
		return not $RayCast2D_UP.is_colliding()
	if new_direction == Vector2.DOWN:
		return not $RayCast2D_DOWN.is_colliding()
	if new_direction == Vector2.LEFT:
		return not $RayCast2D_LEFT.is_colliding()
	if new_direction == Vector2.RIGHT:
		return not $RayCast2D_RIGHT.is_colliding()
	return false

# ELEGIR DIRECCIÓN ALEATORIA

func choose_random_direction():
	var possible_directions = [
		Vector2.UP,
		Vector2.DOWN,
		Vector2.LEFT,
		Vector2.RIGHT
	]
	possible_directions.shuffle()
	for new_direction in possible_directions:
		if can_move(new_direction):
			direction = new_direction
			update_animation()
			return

# ANIMACIÓN

func update_animation():
	# Si existe una animación específica para cada dirección
	if direction == Vector2.UP:
		if $AnimatedSprite2D.sprite_frames.has_animation("walk_up"):
			$AnimatedSprite2D.play("walk_up")
		elif $AnimatedSprite2D.sprite_frames.has_animation("walk"):
			$AnimatedSprite2D.play("walk")
	elif direction == Vector2.DOWN:
		if $AnimatedSprite2D.sprite_frames.has_animation("walk_down"):
			$AnimatedSprite2D.play("walk_down")
		elif $AnimatedSprite2D.sprite_frames.has_animation("walk"):
			$AnimatedSprite2D.play("walk")
	elif direction == Vector2.LEFT:
		if $AnimatedSprite2D.sprite_frames.has_animation("walk_left"):
			$AnimatedSprite2D.play("walk_left")
		elif $AnimatedSprite2D.sprite_frames.has_animation("walk"):
			$AnimatedSprite2D.play("walk")
	elif direction == Vector2.RIGHT:
		if $AnimatedSprite2D.sprite_frames.has_animation("walk_right"):
			$AnimatedSprite2D.play("walk_right")
		elif $AnimatedSprite2D.sprite_frames.has_animation("walk"):
			$AnimatedSprite2D.play("walk")

# COMENZAR A ESCONDERSE

func start_hiding():
	current_state = State.HIDING
	velocity = Vector2.ZERO
	# Animación de desaparecer
	if $AnimatedSprite2D.sprite_frames.has_animation("hide"):
		$AnimatedSprite2D.play("hide")
		await $AnimatedSprite2D.animation_finished
	# Volver a esconder
	hide_leever()

# ESTADO: ESCONDIÉNDOSE

func hiding_state():
	velocity = Vector2.ZERO
