extends Control

onready var timer = $timer

func _ready():
	timer.connect("timeout", self, "on_time_out")


func on_time_out():
	pass