extends Node2D

func _on_StartDialogsButton_pressed():
	$DialogManager.startDialog()


func _on_DialogManager_dialogs_done():
	print("Dialogs done !")
