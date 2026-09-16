extends Control

func _ready():
	$AnimationPlayer.play("RESET")
	hide()


func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	hide()

func pause():
	show()
	get_tree().paused = true
	$AnimationPlayer.play("blur")

func testEsc():
	if Input.is_action_just_pressed("esc") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("esc") and get_tree().paused == true:
		resume()

func testRestart():
	if Input.is_action_just_pressed("restart") and get_tree().paused == true:
		get_tree().reload_current_scene()

func testQuit():
	if Input.is_action_just_pressed("quit") and get_tree().paused == true:
		get_tree().quit()





func _process(_delta):
	testEsc()
	testRestart()
	testQuit()
