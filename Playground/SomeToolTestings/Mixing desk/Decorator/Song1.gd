extends SongTemplate

func autoSkipToLoop(loop_index:int)->int:
	match(loop_index):
		0:
			return 1
	return -1
