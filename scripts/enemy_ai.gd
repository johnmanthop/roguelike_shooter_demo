class_name EnemyAI extends Node

var enemy_list: Array
var pathfindinder = AStar2D.new()

func set_enemies(el: Array):
	enemy_list = el
	

