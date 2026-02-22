class_name ComponentCore extends RefCounted

var _class_type: GDScript
var _component_name: StringName


func _init(class_type: GDScript) -> void:
	_class_type = class_type
	_component_name = _class_type.get_global_name()


func name() -> StringName:
	return _component_name


## If component parent has component of specified type
## Passed callable will be executed with the component instance as a parameter
func invoke_on_component(component_parent: Node,\
						invocation: Callable) -> bool:
	if not component_parent.has_meta(_component_name):
		return false
	invocation.call(component_parent.get_meta(_component_name))
	return true


## Retrieves component from parent
func get_from(component_parent: Node) -> Node:
	if not component_parent.has_meta(_component_name):
		return null
	return component_parent.get_meta(_component_name)


func get_of_type_from(component_parent: Node) -> Node:
	for child in component_parent.get_children():
		if is_instance_of(child, _class_type):
			return child
	return null


#func depend_on_type_from(component_parent: Node, function: Callable) -> ComponentDependency:
	#return ComponentDependency.new(function, _class_type, component_parent)
#
#
#func get_component_observer_in(component_parent: Node) -> ComponentObserver:
	#return ComponentObserver.new(_class_type, component_parent)
