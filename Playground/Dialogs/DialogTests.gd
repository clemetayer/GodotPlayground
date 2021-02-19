extends Node2D

func _on_StartDialogsButton_pressed():
	$DialogManagerNarrator.startDialog()

func _on_StartCharactersButton_pressed():
	$DialogManagerCharacters.startDialog()

func _on_DialogManager_dialogs_done():
	print("Dialogs narrator done !")

func _on_DialogManagerCharacters_dialogs_done():
	print("Dialogs characters done !")
