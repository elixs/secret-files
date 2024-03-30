extends Area2D


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	if is_instance_valid(self):
		if !area.has_method("is_file_grabber"):
			return
		var file_grabber = area
		if file_grabber:
			file_grabber.has_files = true
			queue_free()
