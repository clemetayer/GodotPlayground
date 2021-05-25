tool
extends MainTracksTemplate

var lastPianoTime = 0

# check if some tracks should be disabled
func _process(_delta):
	if not Engine.editor_hint:
		handleTrackDependencies()

# stops or plays a track depending on another
func handleTrackDependencies():
	if($Piano.playing and 
		not $UltraSoft.playing and 
		not $OtherParts.playing):
			if(lastPianoTime > $Piano.get_playback_position()):
				$UltraSoft.play(0.0)
				SignalManager.emit_track_played("UltraSoft")
			else:
				lastPianoTime = $Piano.get_playback_position()
	if($OtherParts.playing):
		var time = $OtherParts.get_playback_position()
		if(time >= 96.0 and time <= 112):
			$Piano.stop()
			SignalManager.emit_track_stopped("Piano")
		else:
			if(not $Piano.playing and TRACKS[0].play):
				$Piano.play(0.0)
				SignalManager.emit_track_played("Piano")
		if(time >= 160 and time <= 176):
			$UltraSoft.stop()
			SignalManager.emit_track_stopped("UltraSoft")
		else:
			if(not $UltraSoft.playing and TRACKS[1].play):
				$UltraSoft.play(0.0)
				SignalManager.emit_track_played("UltraSoft")
