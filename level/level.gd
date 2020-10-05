extends Node2D

const LEVEL_SIZE : int = 50
const MIN_ROOM_DIMENSION : int = 8
const MAX_ROOM_DIMENSION : int = 11
const NUM_ROOMS : int = 6
const TILE_SIZE : int = 64

const GAME_OVER : PackedScene = preload("res://mainTitle/GameOver.tscn")
const WALL : PackedScene = preload("res://environment/wall.tscn")
const ENEMY : PackedScene = preload("res://enemy/enemy.tscn")
const REVENGE : PackedScene = preload("res://mainTitle/revenge.tscn")
const PAUSE : PackedScene = preload("res://mainTitle/pause.tscn")

enum Tile {ground, corner1, corner2, corner3, corner4, wall_down, wall_left, wall_right, wall_up, wall}

var current_avenger : String = ""
var current_victim : String = ""
var current_dead : String = ""

var names : Array = ["Antonio", "Jose", "Manuel", "Francisco", "David", "Juan", "Javier", "Daniel", "Diego", "Carlos",
"Jesus", "Alejandro", "Donald", "Miguel", "Adrian", "Enrique", "Ruben", "Vicente", "Mickey", "Zed", "Cain", "Lazaro", "Samson",
"Edmund", "Ismael", "Abraham", "Alex", "Cesar", "Julio", "Xavier", "Albert", "Dross", "Felix", "Ike", "Hector", "Aitor",
"Noah", "Jacob", "Mason", "Liam", "William", "Ethan", "Michael", "Alexander", "James", "Elijah", "Aiden", "Jayden", "Benjamin",
"Matthew", "Logan", "Joseph", "Anthony", "Jackson", "Lucas", "Joshua", "Andrew", "Gabriel", "Samuel", "Isaac", "Carter", "Luke",
"Anakin", "Nathan", "Caleb", "Owen", "Christian", "Henry", "Oliver", "Wyatt", "Jonathan", "Landon", "Jack", "Sebastian",
"Hunter", "Isaiah", "Julian", "Levi", "Aaron", "Eli", "Brayden", "Nicholas", "Connor", "Charles", "Thomas", "Evan", "Jeremiah",
"Gavin", "Cameron", "Jordan", "Jaxon", "Angel", "Tyler", "Robert", "Austin", "Grayson", "Josiah", "Brandon", "Colton", "Dominic",
"Kevin", "Zachary", "Chase", "Will", "Maxwell", "Ian", "Ayden", "Adam", "Parker", "Peter", "Cooper", "Justin", "Dipper", "Nolan",
"Jace", "Lincoln", "Bentley", "Blake", "Easton", "Nathaniel", "Asher", "Mateo", "Tristan", "Bryson", "Kayden", "Brody"]

var relations : Array = ["father", "son", "cousin", "baker", "uncle", "grandpa", "grandson", "lawyer", "chef", "friend", "acupuncturist",
"watchman", "nurse", "surgeon", "dentist", "babysitter", "screenwriter", "photographer", "accountant", "bricklayer", "cashier",
"clown", "counselor", "dancer", "cook", "dustman", "hunter", "librarian", "painter", "pharmacist", "postman", "researcher",
"sailor", "taxi driver", "vet", "window cleaner", "salesman"]

var dead : bool = false
var music : Array = [preload("res://assets/music/0.wav"), preload("res://assets/music/1.wav"), preload("res://assets/music/2.wav"),
preload("res://assets/music/3.wav"), preload("res://assets/music/4.wav"), preload("res://assets/music/5.wav"), preload("res://assets/music/6.wav"), preload("res://assets/music/7.wav")]
var current_level : int = 0
var rooms : Array = []
var min_enemies : int = 1

var score : int = 0
var revenges : int = 0

#this executes at the start of the scene
func _ready():
	randomize()
	revenge()
	$cursor.playing = true
	build_level()

#This function creates the level
func build_level():
	$cursor.modulate = Color(randf(), randf(), randf())
	$player.modulate = Color(randf(), randf(), randf())
	var r : float = randf()
	var g : float = randf()
	var b : float = randf()
	for x in get_children():
		if x is TileMap:
			x.modulate = Color(r, g, b)
	$AudioStreamPlayer.stream = music[randi() % music.size()]
	$AudioStreamPlayer.play()
	for x in get_children():
		if x is TileMap:
			x.clear()
		elif "enemy" in x.name or x is StaticBody2D or x is Area2D:
			x.queue_free()
	rooms.clear()
	for x in range(LEVEL_SIZE):
		for y in range(LEVEL_SIZE):
			$TileMap.set_cell(x, y, Tile.wall)
	var free_regions : Array = [Rect2(Vector2(2,2), Vector2(LEVEL_SIZE, LEVEL_SIZE) - Vector2(4, 4))]
	for _x in range(NUM_ROOMS):
		add_room(free_regions)
		if free_regions.empty():
			break
	connect_rooms()
	apply_borders()
	place_player()
	place_enemies()

#This function generates a room
func add_room(free_regions : Array):
	var region : Rect2 = free_regions[randi() % free_regions.size()]

	var size_x : int = MIN_ROOM_DIMENSION
	if region.size.x > MIN_ROOM_DIMENSION:
		size_x += randi() % int(region.size.x - MIN_ROOM_DIMENSION)

	var size_y : int = MIN_ROOM_DIMENSION
	if region.size.y > MIN_ROOM_DIMENSION:
		size_y += randi() % int(region.size.y - MIN_ROOM_DIMENSION)

	size_x = int(min(size_x, MAX_ROOM_DIMENSION))
	size_y = int(min(size_y, MAX_ROOM_DIMENSION))

	var start_x : int = int(region.position.x)
	if region.size.x > size_x:
		start_x += randi() % int(region.size.x - size_x)

	var start_y : int = int(region.position.y)
	if region.size.y > size_y:
		start_y += randi() % int(region.size.y - size_y)

	var room : Rect2 = Rect2(start_x, start_y, size_x, size_y)
	rooms.append(room)

	$TileMap.set_cell(start_x, start_y, Tile.corner1)
	$TileMap.set_cell(start_x + size_x - 1, start_y, Tile.corner2)
	$TileMap.set_cell(start_x, start_y + size_y - 1, Tile.corner3)
	$TileMap.set_cell(start_x + size_x - 1, start_y + size_y - 1, Tile.corner4)
	for x in range(start_x + 1, start_x + size_x - 1):
		$TileMap.set_cell(x, start_y, Tile.wall_up)
		$TileMap.set_cell(x, start_y + size_y - 1, Tile.wall_down)


	for y in range(start_y + 1, start_y + size_y - 1):
		$TileMap.set_cell(start_x, y, Tile.wall_right)
		$TileMap.set_cell(start_x + size_x - 1, y, Tile.wall_left)
		
		for x in range(start_x + 1, start_x + size_x - 1):
			$TileMap.set_cell(x, y, Tile.ground)

	cut_regions(free_regions, room)

#This function updates the free regions variable
func cut_regions(free_regions : Array, region_to_remove : Rect2):
	var removal_queue : Array = []
	var addition_queue : Array = []

	for region in free_regions:
		if region.intersects(region_to_remove):
			removal_queue.append(region)
			var leftover_left : int = region_to_remove.position.x - region.position.x - 1
			var leftover_right : int = region.end.x - region_to_remove.end.x - 1
			var leftover_above : int = region_to_remove.position.y - region.position.y - 1
			var leftover_below : int = region.end.y - region_to_remove.end.y - 1
			if leftover_left >= MIN_ROOM_DIMENSION:
				addition_queue.append(Rect2(region.position, Vector2(leftover_left, region.size.y)))
			if leftover_right >= MIN_ROOM_DIMENSION:
				addition_queue.append(Rect2(Vector2(region_to_remove.end.x + 1, region.position.y), Vector2(leftover_right, region.size.y)))
			if leftover_above >= MIN_ROOM_DIMENSION:
				addition_queue.append(Rect2(region.position, Vector2(region.size.x, leftover_above)))
			if leftover_below >= MIN_ROOM_DIMENSION:
				addition_queue.append(Rect2(Vector2(region.position.x, region_to_remove.end.y + 1), Vector2(region.size.x, leftover_below)))
	for region in removal_queue:
		free_regions.erase(region)
	for region in addition_queue:
		free_regions.append(region)

#Connect the rooms using the AL-MIGHTY A-STAR graph
func connect_rooms():
	var graph : AStar = AStar.new()
	var point_id : int = 0
	for x in range(LEVEL_SIZE):
		for y in range(LEVEL_SIZE):
			if $TileMap.get_cell(x, y) != Tile.ground:
				graph.add_point(point_id, Vector3(x, y, 0))
				if x > 0 && $TileMap.get_cell(x -1, y) != Tile.ground:
					var left_point : int = graph.get_closest_point(Vector3(x - 1, y, 0))
					graph.connect_points(point_id, left_point)
				if y > 0 && $TileMap.get_cell(x, y - 1) != Tile.ground:
					var above_point : int = graph.get_closest_point(Vector3(x, y - 1, 0))
					graph.connect_points(point_id, above_point)
				point_id += 1
	for x in range(rooms.size() - 1):
		add_random_connection(graph, rooms[x], rooms[x + 1])

#Creates a random connection between rooms
func add_random_connection(graph : AStar, start_room : Rect2, end_room : Rect2):
	var start_position : Vector3 = pick_random_door_location(start_room)
	var end_position : Vector3 = pick_random_door_location(end_room)
	var closest_start_point : int = graph.get_closest_point(start_position)
	var closest_end_point : int = graph.get_closest_point(end_position)
	var path : Array = graph.get_point_path(closest_start_point, closest_end_point)
	assert(path)
	$TileMap.set_cell(start_position.x, start_position.y, Tile.ground)
	$TileMap.set_cell(end_position.x, end_position.y, Tile.ground)
	for position in path:
		$TileMap.set_cell(position.x, position.y, Tile.ground)

#Return a random edge block of a room
func pick_random_door_location(room : Rect2) -> Vector3:
	var options : Array = []
	for x in range(room.position.x + 1, room.end.x - 2):
		options.append(Vector3(x, room.position.y, 0))
		options.append(Vector3(x, room.end.y - 1, 0))
	for y in range(room.position.y + 1, room.end.y - 2):
		options.append(Vector3(room.position.x, y, 0))
		options.append(Vector3(room.end.x - 1, y, 0))
	return options[randi() % options.size()]

#This functions places the player in the dungeon
func place_player():
	var start_room : Rect2 = rooms.front()
	var player_x : int = int(start_room.position.x + 1 + randi() % int(start_room.size.x - 2))
	var player_y : int = int(start_room.position.y + 1 + randi() % int(start_room.size.y - 2))
	$player.global_position = Vector2(player_x, player_y) * TILE_SIZE

#This function makes the tilemap looks a bit more fancy
func apply_borders():
	var check_tile : Array = []
	for x in range(LEVEL_SIZE):
		for y in range(LEVEL_SIZE):
			if $TileMap.get_cell(x, y) == Tile.ground:
				if $TileMap.get_cell(x - 1, y - 1) != Tile.ground and not Vector2(x - 1, y - 1) in check_tile:
					check_tile.append(Vector2(x - 1, y - 1))
				if $TileMap.get_cell(x, y - 1) != Tile.ground and not Vector2(x, y - 1) in check_tile:
					check_tile.append(Vector2(x, y - 1))
				if $TileMap.get_cell(x + 1, y - 1) != Tile.ground and not Vector2(x + 1, y - 1) in check_tile:
					check_tile.append(Vector2(x + 1, y - 1))
				if $TileMap.get_cell(x - 1, y) !=  Tile.ground and not Vector2(x - 1, y) in check_tile:
					check_tile.append(Vector2(x - 1, y))
				if $TileMap.get_cell(x + 1, y) != Tile.ground and not Vector2(x + 1, y) in check_tile:
					check_tile.append(Vector2(x + 1, y))
				if $TileMap.get_cell(x - 1, y + 1) != Tile.ground and not Vector2(x - 1, y + 1) in check_tile:
					check_tile.append(Vector2(x - 1, y + 1))
				if $TileMap.get_cell(x, y + 1) != Tile.ground and not Vector2(x, y + 1) in check_tile:
					check_tile.append(Vector2(x, y + 1))
				if $TileMap.get_cell(x + 1, y + 1) != Tile.ground and not Vector2(x + 1, y + 1) in check_tile:
					check_tile.append(Vector2(x + 1, y + 1))
	for tile in check_tile:
		var wall : StaticBody2D = WALL.instance()
		add_child(wall)
		wall.global_position = Vector2(tile.x, tile.y) * 64
		if $TileMap.get_cell(tile.x, tile.y + 1) == Tile.ground:
			$wallup.set_cell(tile.x, tile.y, 0)
		if $TileMap.get_cell(tile.x + 1, tile.y) == Tile.ground:
			$wallleft.set_cell(tile.x, tile.y, 0)
		if $TileMap.get_cell(tile.x - 1, tile.y) == Tile.ground:
			$wallright.set_cell(tile.x, tile.y, 0)
		if $TileMap.get_cell(tile.x, tile.y - 1) == Tile.ground:
			$walldown.set_cell(tile.x, tile.y, 0)
		if $TileMap.get_cell(tile.x + 1, tile.y + 1) == Tile.ground:
			$corner1.set_cell(tile.x, tile.y, 0)
		if $TileMap.get_cell(tile.x - 1, tile.y + 1) == Tile.ground:
			$corner2.set_cell(tile.x, tile.y, 0)
		if $TileMap.get_cell(tile.x + 1, tile.y - 1) == Tile.ground:
			$corner3.set_cell(tile.x, tile.y, 0)
		if $TileMap.get_cell(tile.x - 1, tile.y - 1) == Tile.ground:
			$corner4.set_cell(tile.x, tile.y, 0)

#This executes every frame
func _physics_process(_delta):
	if ! dead:
		if Input.is_action_just_pressed("pause"):
			add_child(PAUSE.instance())
			get_tree().paused = true
		$cursor.global_position = get_global_mouse_position()
		var enemy_counter : int = 0
		for x in get_children():
			if "enemy" in x.name and ! x.dead:
				enemy_counter += 1
				x.velocity = get_movement_intention(x) * x.speed
		$CanvasLayer/Label.text = str(enemy_counter) + (" enemy left." if enemy_counter == 1 else " enemies left.")
		if enemy_counter == 0:
			revenges += 1
			min_enemies += 1
			revenge()
			build_level()

#This function gets the movement intention of an enemy
func get_movement_intention(enemy : KinematicBody2D) -> Vector2:
	var mov_int : Vector2 = Vector2()
	var dist_player : float = abs(enemy.global_position.x - $player.global_position.x) + abs(enemy.global_position.y - $player.global_position.y)
	if dist_player < 500 and dist_player > 100:
		mov_int = Vector2($player.global_position.x - enemy.global_position.x, $player.global_position.y - enemy.global_position.y)
	if dist_player < 500:
		enemy.rotation_degrees = 180 - rad2deg(atan2($player.global_position.x - enemy.global_position.x, $player.global_position.y - enemy.global_position.y))
		enemy.shooting = true
		enemy.dir_player = Vector2($player.global_position.x - enemy.global_position.x, $player.global_position.y - enemy.global_position.y)
	return mov_int.normalized()

#This function places the enemies
func place_enemies():
	for x in range(1, rooms.size()):
		var spawn_room : Rect2 = rooms[x]
		for _y in range(min_enemies + randi() % 3):
			var enemy : KinematicBody2D = ENEMY.instance()
			add_child(enemy)
			var enemy_x : int = int(spawn_room.position.x + 1 + randi() % int(spawn_room.size.x - 2))
			var enemy_y : int = int(spawn_room.position.y + 1 + randi() % int(spawn_room.size.y - 2))
			enemy.global_position = Vector2(enemy_x, enemy_y) * TILE_SIZE

#Replay the song
func _on_AudioStreamPlayer_finished():
	$AudioStreamPlayer.play()

#This executes when the player die
func game_over():
	dead = true
	$cursor.queue_free()
	add_child(GAME_OVER.instance())

#Set a new revenge
func revenge():
	$player.current_weapon = randi() % 12
	var current_revenge : Control = REVENGE.instance()
	add_child(current_revenge)
	
	if current_victim == "":
		current_avenger = names[randi() % names.size()]
		current_dead = names[randi() % names.size()]
		current_victim = names[randi() % names.size()]
	else:
		current_dead = current_victim
		current_victim = current_avenger
		current_avenger = names[randi() % names.size()]
	current_revenge.get_node("CanvasLayer/Label").text = "You are " + current_avenger + ".\n" + current_victim + " killed " + current_dead + ", your "+ relations[randi() % relations.size()] +".\nTake revenge of him!"
	$CanvasLayer/ven.text = "Kill " + current_victim + " and his band"

#increase the score in one
func up_score():
	score += 1
	$CanvasLayer/score.text = "Score = " + str(score)
