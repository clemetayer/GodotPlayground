extends DefaultSong

# returns the next loop index 
func endLoop(loop_index:int) -> int:
	match(loop_index):
		0:
			return 1
	return -1
