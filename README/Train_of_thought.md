核心一：子弹物理体选择 —— Area2D

为什么选 Area2D？

节点类型 物理模拟 性能 适用场景
RigidBody2D 全物理（重力、力、反弹） 高 需要物理交互的物体（保龄球、炮弹）
CharacterBody2D 代码驱动，手动移动 中 玩家、敌人
Area2D 只检测，不模拟 最低 子弹、陷阱、道具

子弹的特性

· 不需要重力
· 不需要被碰撞弹开
· 只需要知道“碰到谁了”

结论：Area2D 性能最优，职责单一。

---

核心二：输入处理层级 —— _unhandled_input

事件传递顺序

```
输入事件
    ↓
[1] GUI 控件（Button 等）—— 如果“吃掉”事件，流程终止
    ↓ 没被吃
[2] _input(event) —— 通用输入
    ↓ 没处理
[3] _unhandled_input(event) —— 兜底，没人要的输入
```

为什么推荐 _unhandled_input 做游戏逻辑？

场景 _input _unhandled_input
无 UI 时 能收到 能收到
UI 弹窗时 UI 可能吃掉事件，收不到 只收 UI 不要的
弹窗时是否开枪 可能误触发 取决于 UI 是否占用了该键

核心思想：游戏逻辑应该放在最后一道防线，不干扰 UI，也不被 UI 干扰。

---

核心三：枪口对齐 —— Transform 与坐标转换

问题本质

子弹需要出现在枪口的世界坐标，而不是玩家中心。

两种方案

方案 A：子节点法（推荐）

```
Player
├── Muzzle (Marker2D)  ← 手动调整位置到枪尖
```

```gdscript
bullet.global_position = $Muzzle.global_position
```

原理：

· Muzzle.global_position = Player.global_position + Muzzle.position
· Godot 自动完成局部→世界转换

方案 B：代码计算

```gdscript
var offset = 20
var direction = Vector2.RIGHT.rotated(rotation)
bullet.global_position = global_position + direction * offset
```

为什么必须先 add_child 再设 global_position？

```
错误顺序：
1. bullet.global_position = 枪口位置  ← 子弹记录世界坐标
2. add_child(bullet)                 ← 父节点变化，坐标被重新计算覆盖

正确顺序：
1. add_child(bullet)                 ← 父节点固定
2. bullet.global_position = 枪口位置 ← 直接生效，不被覆盖
```

核心思想：设置 global_position 必须在节点进入场景树之后。

---

三个问题的共同主线

问题 核心原则
子弹用 Area2D 职责单一：只做检测，不做物理
输入用 _unhandled_input 分层解耦：UI 优先，游戏兜底
枪口对齐 坐标系明确：局部转世界，时机正确

---

一句话总结

· Area2D：轻量级探测器
· _unhandled_input：UI 吃剩下的归我
· Muzzle 子节点 + 先 add 后设位置：坐标转换的正确时机

这三个问题涵盖了 Godot 开发中最核心的三个概念：物理体选择、输入分层、坐标变换。搞懂它们，你就跨过了新手门槛。