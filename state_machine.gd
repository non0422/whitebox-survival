extends Node
class_name StateMachine

#先暴露一个接口，方便外部调用
@export var initial_state:State

var current_state:State
var states:Dictionary = {}

func _ready() -> void:
    #将所有子节点添加到状态字典中
    for child in get_children():
        if child is State:
            states[child.name] = child
            child.transitioned.connect(_on_state_transitioned)  #连接状态转换信号
    #设置初始状态
    if initial_state:
        initial_state._enter()
        current_state = initial_state  

func _physics_process(delta: float) -> void:
    if current_state:
        current_state._physics_process(delta)

func _process(delta: float) -> void:
    if current_state:
        current_state.update(delta)


func _on_state_transitioned(state:State, new_state_name:String) -> void:
    if state != current_state:
        return  #确保只有当前状态能触发转换
    
    var new_state = states.get(new_state_name.to_lower())
    if !new_state:
        push_error("State '%s' not found in StateMachine." % new_state_name)
        return

    if current_state:
        current_state._exit()  #退出当前状态

    new_state._enter()  #进入新状态
    current_state = new_state  #更新当前状态    
    print("Transitioned to state: %s" % new_state_name)
