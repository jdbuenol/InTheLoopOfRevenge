extends Node2D

const LEVEL_SIZE : int = 50
const MIN_ROOM_DIMENSION : int = 5
const MAX_ROOM_DIMENSION : int = 8
const NUM_ROOMS : int = 6
const TILE_SIZE : int = 64

enum Tile {ground, corner1, corner2, corner3, corner4, wall_down, wall_left, wall_right, wall_up, wall}

var current_level : int = 0
var rooms : Array = []

#this executes at the start of the scene
func _ready():
	randomize()
	build_level()

#This function creates the level
func build_level():
	$TileMap.clear()
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
