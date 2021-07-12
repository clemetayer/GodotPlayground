extends Node

func _ready():
	$Buttons/SkipLoopCenter/SkipLoopButton.hide()

func _on_SkipLoopButton_pressed():
	get_node("Dialogs/Characters/8").NEXT_DIALOGS[0] = "../9"

func _on_7_dialog_done():
	$Buttons/SkipLoopCenter/SkipLoopButton.show()

func _on_9_dialog_done():
	$Buttons/SkipLoopCenter/SkipLoopButton.hide()	
	get_node("Dialogs/Characters/8").NEXT_DIALOGS[0] = "."

func _on_MethodTriggerButton_pressed():
	$Dialogs/Narrator.triggerMethodOnCurrentDialogs("testMethod",[12,"test"])
	$Dialogs/Characters.triggerMethodOnCurrentDialogs("testMethod",[12,"test"])

func _on_StartDialogsButton_pressed():
	$Dialogs/Narrator.startDialogs()

func _on_StartCharactersButton_pressed():
	$Dialogs/Characters.startDialogs()

func _on_StopDialogsButton_pressed():
	$Dialogs/Narrator.stopCurrentDialogs()


func _on_StopCharactersButton_pressed():
	$Dialogs/Characters.stopCurrentDialogs()
