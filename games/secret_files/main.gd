extends Node2D

@export var player_scene: PackedScene
@export var file_grabber_scene: PackedScene
@export var files_scene: PackedScene

var _player_with_files: Chimerin = null

@onready var players: Node2D = $Players
@onready var spawns: Node2D = $Spawns
@onready var kill_timer: Timer = $KillTimer
@onready var score_timer: Timer = $ScoreTimer
@onready var game_timer: Timer = $GameTimer
@onready var score_container: VBoxContainer = %ScoreContainer


func _ready() -> void:
	if not player_scene:
		Debug.log("No player scene selected")
		return
	for i in Game.players.size():
		var player_data = Game.players[i]
		var player_inst = player_scene.instantiate() as Chimerin
		player_inst.global_position = spawns.get_child(i).global_position
		players.add_child(player_inst)
		player_inst.setup(player_data)
		
		var file_grabber_inst = file_grabber_scene.instantiate()
		player_inst.add_child(file_grabber_inst)
		file_grabber_inst.files_taken.connect(_on_files_taken.bind(player_inst))
		
		var hbox = HBoxContainer.new()
		var color_rect = ColorRect.new()
		color_rect.custom_minimum_size = Vector2.ONE * 100
		color_rect.color = player_data.primary_color
		hbox.add_child(color_rect)
		var label = Label.new()
		hbox.add_child(label)
		label.text = str(player_data.local_score)
		score_container.add_child(hbox)
	
	kill_timer.timeout.connect(_on_kill_timeout)
	score_timer.timeout.connect(_on_score_timeout)
	game_timer.timeout.connect(func(): Game.end_game())



func _process(delta: float) -> void:
	for i in Game.players.size():
		var player_data = Game.players[i]
		var label = score_container.get_child(i).get_child(1) as Label
		label.text = str(player_data.local_score)


func _on_files_taken(player: Chimerin) -> void:
	_player_with_files = player
	kill_timer.start()
	score_timer.start()


func _on_kill_timeout() -> void:
	Debug.log("killed")
	score_timer.stop()
	var player = _player_with_files
	var file_grabber = _get_file_grabber(player)
	_player_with_files = null
	player.set_physics_process(false)
	file_grabber.has_files = false
	file_grabber.disable(true)
	_drop_files(player)
	await get_tree().create_timer(2).timeout
	player.set_physics_process(true)
	file_grabber.disable(false)


func _on_score_timeout() -> void:
	if _player_with_files:
		_player_with_files.data.local_score += 100


func _drop_files(player: Chimerin) -> void:
	var files_inst = files_scene.instantiate()
	files_inst.global_position = player.global_position + Vector2.DOWN.rotated(randf() * 2 * PI) * 150
	add_child(files_inst)
	move_child(files_inst, 1)


# TODO use static version from FileGrabber on Godot 4.3
func _get_file_grabber(player: Chimerin):
	for child in player.get_children():
		if child.has_method("is_file_grabber"):
			return child
	return null
