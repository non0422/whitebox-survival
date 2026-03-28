
1. preload — 提前加载

适用场景：

· 资源一定会用到（比如子弹、玩家角色、常用UI）
· 希望游戏运行流畅，避免中途卡顿
· 资源较小，加载速度快

例子：

```gdscript
var bullet_scene = preload("res://bullet.tscn")   # 子弹肯定要用
var player_scene = preload("res://player.tscn")   # 玩家肯定要用
var enemy_scene = preload("res://enemy.tscn")     # 敌人经常出现
```

优点： 运行时不卡顿
缺点： 游戏启动稍慢（因为要提前加载）

---

2. load — 需要时才加载

适用场景：

· 资源不一定会用到（比如特定关卡的BOSS、稀有道具）
· 资源很大，不想提前占用内存
· 动态加载，比如玩家选择不同皮肤时才加载对应图片

例子：

```gdscript
# 玩家进入下一关才加载BOSS场景
if level == 5:
    var boss_scene = load("res://boss.tscn")
    add_child(boss_scene.instantiate())
```

优点： 节省启动时间和内存
缺点： 使用时可能短暂卡顿

---

3. @onready — 等节点准备好了再执行

适用场景：

· 获取子节点（$Muzzle、$Sprite）
· 获取其他节点（get_node("../Player")）
· 任何需要节点存在的操作

例子：

```gdscript
@onready var muzzle = $Muzzle                    # 子节点
@onready var animation = $AnimationPlayer        # 子节点
@onready var player = get_node("../Player")      # 兄弟节点
```

优点： 避免“节点还没创建就调用”的错误
缺点： 不能在 _ready() 之前使用这些变量

---

对比表格

概念 什么时候用 什么时候不用
preload 资源一定会用，追求运行流畅 资源很大且不一定用，不想拖慢启动
load 资源不一定用，或太大不想提前加载 资源经常用，用 preload 更好
@onready 获取节点引用（$、get_node） 普通变量赋值、preload 资源

---

常见组合用法

```gdscript
extends CharacterBody2D

# 1. 一定会用的资源用 preload
var bullet_scene = preload("res://bullet.tscn")

# 2. 需要获取子节点用 @onready
@onready var muzzle = $Muzzle
@onready var sprite = $Sprite2D

# 3. 大资源或不一定用的用 load（在函数里）
func spawn_boss():
    var boss_scene = load("res://boss.tscn")
    add_child(boss_scene.instantiate())
```

---

一句话总结：

preload = 一定会用 → 提前准备
load = 不一定用 → 用的时候再说
@onready = 需要节点 → 等它准备好