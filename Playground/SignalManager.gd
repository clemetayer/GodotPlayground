extends Node

# global signal management

signal track_played(track_name)
signal track_stopped(track_name)

func emit_track_played(track_name : String) -> void:
	emit_signal("track_played", track_name)

func emit_track_stopped(track_name : String) -> void:
	emit_signal("track_stopped", track_name)
