extends KinematicBody2D

var motion = Vector2(0, 0)

var up_dir = Vector2(0, -1)
var graity = 30

var anmation
var jump_force


func move():
	motion.y -= graity
	motion = move_and_slide(motion, up_dir)