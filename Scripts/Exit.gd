#This script is used to proveed to the next level
extends Area2D

func _on_area_enter( area ):
	print("entered: " + area.get_name())
	#if the area that entered the item was the player
	if area.is_in_group("Player"):
		print(area.get_pos())
		#adds one to level
		Game.level += 1
		#this wait prevents the player from moving beofre the level has started
		yield(utils.create_timer(0.2), "timeout")
		#updates the current level text
		get_tree().call_group(0, "UI", "_on_level_Changed", Game.level)
		#loads the "next level" aka reloads the current game scene
		get_tree().reload_current_scene()
