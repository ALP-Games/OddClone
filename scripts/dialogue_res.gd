class_name DialogueRes extends Resource

@export_multiline var dialogue_text: String
@export_custom(PROPERTY_HINT_NONE, "suffix:a second") var characters_over_time: float = 60.0
@export var wait_before_start: float = 1.0
@export var stay_after_finish: float = 10.0
