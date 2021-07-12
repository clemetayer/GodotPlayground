tool
extends DialogBoxChoices

##### USER FUNCTIONS #####
# dialog box custom function, returning a boolean for the sake of testing
func test_function(param1, param2) -> bool:
	if(param1 == 1 and param2 == true):
		return true
	return false
