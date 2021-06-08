extends Node

func _on_StartDialogsButton_pressed():
	$DialogManagerNarrator.startDialog()

func _on_StartCharactersButton_pressed():
	$DialogManagerCharacters.startDialog()

func _on_DialogManager_dialogs_done():
	print("Dialogs narrator done !")

func _on_DialogManagerCharacters_dialogs_done():
	# TODO : character 1 speaking into character 2 speaking (in same dialog)
	# character 1 cancels character 2
	# character 1 then character 2 but with an external button press (tests triggerMethod and instant_start)
	# both characters speaking at the same time (same dialog)
	# both characters speaking at the same time (different dialog)
	# method trigerring that does domething : button showing that makes the dialog loop until button pressed
	# external event that cancels current dialogs
	print("Dialogs characters done !")

func _on_DialogManagerNarrator_custom_signal(name, value):
	match(name):
		"Narrator-3-1":
			match(value):
				1:
					$DialogManagerNarrator.startNextOnNames(["Narrator-4-1"])
				2:
					$DialogManagerNarrator.startNextOnNames(["Narrator-4-2"])
