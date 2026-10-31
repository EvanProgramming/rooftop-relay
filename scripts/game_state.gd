extends RefCounted

const REQUIRED_LETTERS: int = 3
const MAX_HEARTS: int = 3

var letters_collected: int = 0
var hearts: int = MAX_HEARTS
var finished: bool = false
var game_over: bool = false


func reset() -> void:
	letters_collected = 0
	hearts = MAX_HEARTS
	finished = false
	game_over = false


func collect_letter() -> bool:
	if game_over or finished or letters_collected >= REQUIRED_LETTERS:
		return false
	letters_collected += 1
	return true


func try_finish() -> bool:
	if game_over or finished or letters_collected < REQUIRED_LETTERS:
		return false
	finished = true
	return true


func take_hit() -> bool:
	if game_over or finished:
		return false
	hearts = maxi(hearts - 1, 0)
	if hearts == 0:
		game_over = true
	return true
