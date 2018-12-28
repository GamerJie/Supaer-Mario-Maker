extends Node2D

func _ready():
	smmdb.connect("on_http_data", self, "on_get_maps")
	smmdb.req_maps(0, 1)
	# smmdb.test_download("5c24d9e48a410a6e497f75f8")

func on_get_maps(data):
	if data[0] != null:
		smmdb.test_download(data[0].id)