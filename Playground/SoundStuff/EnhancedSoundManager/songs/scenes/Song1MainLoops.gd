tool
extends MainLoopsTemplate

# check if some tracks should be disabled
func _process(_delta):
	if not Engine.editor_hint:
		handleTrackDependencies()

# stops or plays a track depending on another
func handleTrackDependencies():
	if($OtherParts.playing):
		var time = $OtherParts.get_playback_position()
		if(time >= 96.0 and time <= 112):
			$Piano.stop()
		else:
			if(not $Piano.playing and LOOPS[0].play):
				$Piano.play(0.0)
		if(time >= 160 and time <= 176):
			$UltraSoft.stop()
		else:
			if(not $UltraSoft.playing and LOOPS[1].play):
				$UltraSoft.play(0.0)


func _on_Piano_finished():
	if(not $UltraSoft.playing and not $OtherParts.playing): # directly after first part
		$UltraSoft.play(0.0)
	if(isPlaying("Piano")):
		$Piano.play(0.0)

func _on_UltraSoft_finished():
	if(isPlaying("UltraSoft")):
		$UltraSoft.play(0.0)

func _on_OtherParts_finished():
	if(isPlaying("OtherParts")):
		$OtherParts.play(0.0)
