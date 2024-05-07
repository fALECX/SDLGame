class_name MapGenerator
extends Node

const X_DIST := 50
const Y_DIST := 70
const PLACEMENT_RANDOMNESS := 10
const FLOORS := 8
const MAP_WIDTH := 1
const PATHS := 1
const MONSTER_ROOM_WEIGHT := 10.0
const SHOP_ROOM_WEIGHT := 2.5
const CAMPFIRE_ROOM_WEIGHT := 4.0

@export var battle_stats_pool: BattleStatsPool

var random_room_type_weights = {
	Room.Type.MONSTER: 0.0,
	Room.Type.CAMPFIRE: 0.0,
	Room.Type.SHOP: 0.0
}
var random_room_type_total_weight := 0
var map_data: Array[Array]


func generate_map() -> Array[Array]:
	map_data = _generate_initial_grid()
	var starting_points := _get_random_starting_points()

	for j in starting_points:
		var current_j := j
		for i in FLOORS - 1:
			current_j = _setup_connection(i, current_j)

	battle_stats_pool.setup()

	_setup_boss_room()
	_setup_random_room_weights()
	_setup_room_types()

	return map_data


func _generate_initial_grid() -> Array[Array]:
	var result: Array[Array] = []
	
	for i in FLOORS:
		var adjacent_rooms: Array[Room]= []
		
		for j in MAP_WIDTH:
			var current_room := Room.new()
			var offset := Vector2(randf(), randf()) * PLACEMENT_RANDOMNESS
			current_room.position = Vector2(j * X_DIST, i * -Y_DIST) + offset
			current_room.row = i
			current_room.column = j
			current_room.next_rooms = []
			
			# Boss room has a non-random Y
			if i == FLOORS - 1:
				print("is this ever called?")
				current_room.position.y = i * -Y_DIST
			
			adjacent_rooms.append(current_room)
			
		result.append(adjacent_rooms)

	return result


func _get_random_starting_points() -> Array[int]:
	var y_coordinates: Array[int]
	var unique_points: int

	while unique_points < 1:
		unique_points = 0
		y_coordinates = []

		for i in PATHS:
			var starting_point := randi_range(0, MAP_WIDTH - 1)
			if not y_coordinates.has(starting_point):
				unique_points += 1

			y_coordinates.append(starting_point)

	return y_coordinates


func _setup_connection(i: int, j: int) -> int:
	var next_room: Room
	var current_room = map_data[i][j] as Room

	while not next_room:
		var random_j := clampi(randi_range(j - 1, j + 1), 0, MAP_WIDTH - 1)
		next_room = map_data[i + 1][random_j]

	current_room.next_rooms.append(next_room)

	return next_room.column


func _would_cross_existing_path(i: int, j: int, room: Room) -> bool:
	var left_neighbour: Room
	var right_neighbour: Room
	
	if j > 0: # no left neighbour at the left edge
		left_neighbour = map_data[i][j - 1]
	if j < MAP_WIDTH - 1:  # no right neighbour at the right edge
		right_neighbour = map_data[i][j + 1]
		
	if right_neighbour and room.column > j: # can only cross in right dir if candidate is to the right
		for next_room: Room in right_neighbour.next_rooms:
			if next_room.column < room.column:
				return true
			
	if left_neighbour and room.column < j: # can only cross if left dir if candidate is going to the left
		for next_room: Room in left_neighbour.next_rooms:
			if next_room.column > room.column:
				return true
	
	return false


func _setup_boss_room() -> void:
	#mitte ist width / 2
	var middle := floori(MAP_WIDTH * 0.5)
	#letzter raum ist der boss raum
	var boss_room := map_data[FLOORS - 1][middle] as Room

	#alle räume die unter dem boss raum sind, zeigen auf den boss raum
	for j in MAP_WIDTH:
		var current_room = map_data[FLOORS - 2][j] as Room
		if current_room.next_rooms:
			current_room.next_rooms = [] as Array[Room]
			current_room.next_rooms.append(boss_room)
			
	boss_room.type = Room.Type.BOSS
	boss_room.battle_stats = battle_stats_pool.get_random_battle_for_tier(2)


func _setup_random_room_weights() -> void:
	random_room_type_weights[Room.Type.MONSTER] = MONSTER_ROOM_WEIGHT
	random_room_type_weights[Room.Type.CAMPFIRE] = MONSTER_ROOM_WEIGHT + CAMPFIRE_ROOM_WEIGHT
	random_room_type_weights[Room.Type.SHOP] = MONSTER_ROOM_WEIGHT + CAMPFIRE_ROOM_WEIGHT + SHOP_ROOM_WEIGHT
	
	random_room_type_total_weight = random_room_type_weights[Room.Type.SHOP]


func _setup_room_types() -> void:
	# first floor is always a battle
	for room: Room in map_data[0]:
		if room.next_rooms.size() > 0:
			room.type = Room.Type.MONSTER
			room.battle_stats = battle_stats_pool.get_random_battle_for_tier(0)


	for room: Room in map_data[1]:
		if room.next_rooms.size() > 0:
			room.type = Room.Type.MONSTER
			room.battle_stats = battle_stats_pool.get_random_battle_for_tier(0)

	for room: Room in map_data[2]:
		if room.next_rooms.size() > 0:
			room.type = Room.Type.MONSTER
			room.battle_stats = battle_stats_pool.get_random_battle_for_tier(0)

	# 3rd floor is always a shop
	for room: Room in map_data[3]:
		if room.next_rooms.size() > 0:
			room.type = Room.Type.MONSTER
			room.battle_stats = battle_stats_pool.get_random_battle_for_tier(1)

	#4th floor is always a monster room tier 2
	for room: Room in map_data[4]:
		if room.next_rooms.size() > 0:
			room.type = Room.Type.MONSTER
			room.battle_stats = battle_stats_pool.get_random_battle_for_tier(1)

	#4th floor is always a monster room tier 2
	for room: Room in map_data[5]:
		if room.next_rooms.size() > 0:
			room.type = Room.Type.MONSTER
			room.battle_stats = battle_stats_pool.get_random_battle_for_tier(2)

	#4th floor is always a monster room tier 2
	for room: Room in map_data[6]:
		if room.next_rooms.size() > 0:
			room.type = Room.Type.MONSTER
			room.battle_stats = battle_stats_pool.get_random_battle_for_tier(2)

	#4th floor is always a monster room tier 2
	for room: Room in map_data[7]:
		if room.next_rooms.size() > 0:
			room.type = Room.Type.MONSTER
			room.battle_stats = battle_stats_pool.get_random_battle_for_tier(2)

	#9th floor is always a treasure
	#for room: Room in map_data[8]:
	#	if room.next_rooms.size() > 0:
	#			room.type = Room.Type.TREASURE
				
	 #last floor is always a campfire
	#for room: Room in map_data[9]:
	#	if room.next_rooms.size() > 0:
	#		room.type = Room.Type.MONSTER
	#		room.battle_stats = battle_stats_pool.get_random_battle_for_tier(2)

	#. for rest of rooms
	for current_floor in map_data:
		for room: Room in current_floor:
			for next_room: Room in room.next_rooms:
				if next_room.type == Room.Type.NOT_ASSIGNED:
					room.type = Room.Type.MONSTER


func _set_room_randomly(room_to_set: Room) -> void:
	var campfire_below_4 := false
	var consecutive_campfire := true
	var consecutive_shop := true
	var campfire_on_13 := true
	
	var type_candidate: Room.Type
	
	while campfire_below_4 or consecutive_campfire or consecutive_shop or campfire_on_13:
		type_candidate = _get_random_room_type_by_weight()
		
		campfire_below_4 = type_candidate == Room.Type.CAMPFIRE and room_to_set.row < 3
		consecutive_campfire = type_candidate == Room.Type.CAMPFIRE and _room_has_parent_of_type(room_to_set, Room.Type.CAMPFIRE)
		consecutive_shop = type_candidate == Room.Type.SHOP and _room_has_parent_of_type(room_to_set, Room.Type.SHOP)
		campfire_on_13 = type_candidate == Room.Type.CAMPFIRE and room_to_set.row == 12
		
	room_to_set.type = type_candidate
	if type_candidate == Room.Type.MONSTER:
		var tier_for_monster_rooms := 0 if room_to_set.row <= 2 else 1
		room_to_set.battle_stats = battle_stats_pool.get_random_battle_for_tier(tier_for_monster_rooms)


func _room_has_parent_of_type(room: Room, type: Room.Type) -> bool:
	var parents: Array[Room] = []
	# left parent
	if room.column > 0 and room.row > 0:
		var parent_candidate := map_data[room.row - 1][room.column - 1] as Room
		if parent_candidate.next_rooms.has(room):
			parents.append(parent_candidate)
	# parent below
	if room.row > 0:
		var parent_candidate := map_data[room.row - 1][room.column] as Room
		if parent_candidate.next_rooms.has(room):
			parents.append(parent_candidate)
	# right parent
	if room.column < MAP_WIDTH-1 and room.row > 0:
		var parent_candidate := map_data[room.row - 1][room.column + 1] as Room
		if parent_candidate.next_rooms.has(room):
			parents.append(parent_candidate)
	
	for parent: Room in parents:
		if parent.type == type:
			return true
	
	return false


func _get_random_room_type_by_weight() -> Room.Type:
	var roll := randf_range(0.0, random_room_type_total_weight)
	
	for type: Room.Type in random_room_type_weights:
		if random_room_type_weights[type] > roll:
			return type
	
	return Room.Type.MONSTER
