extends Control

@onready var popup = $About

# Called when the node enters the scene tree for the first time.
func _ready():
	get_viewport().set_embedding_subwindows(false)
	
func _on_button_pressed():
	$ClickButton.play()
	popup.show()

func _on_about_close_requested():
	popup.hide()
