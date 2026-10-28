# Whitebox Survival

使用 **Godot / GDScript** 编写的 2D 俯视角射击与敌人 AI 白盒原型。项目通过玩家移动、鼠标瞄准、子弹碰撞、生命值组件和有限状态机，练习从输入到战斗反馈的基础流程。

> 当前仓库主要保存脚本和学习笔记，尚未包含 `project.godot`、`.tscn` 场景和受击闪白着色器，不能直接导入并运行。下文说明现有代码的行为，以及在 Godot 中接入这些脚本所需的配置。

## 已有功能

| 模块 | 当前实现 |
| --- | --- |
| 玩家控制 | 通过四个输入动作移动，角色朝向鼠标位置 |
| 射击 | 响应 `shoot` 动作，在角色前方创建子弹并沿朝向飞行 |
| 子弹碰撞 | 接触物理体后销毁；接触带有 `take_damage()` 方法的区域时传递伤害 |
| 生命值 | `HealthComponent` 管理生命值，发出 `damaged` 和 `died` 信号 |
| 受伤区域 | `HurtboxComponent` 将接收到的伤害转发给关联的生命值组件 |
| 敌人 AI | 在 Idle、Chase、Attack 三个状态之间切换 |
| 死亡处理 | 玩家和敌人的死亡回调调用 `queue_free()` 移除角色 |
| 受击反馈 | 敌人受伤回调驱动 ShaderMaterial 的 `flash_modifier` 参数，需补充材质与信号连接 |

## 战斗流程

玩家通过 Input Map 中的动作移动，使用鼠标控制朝向。触发射击时，`player.gd` 实例化 `res://bullet.tscn`，设置飞行方向、出生位置和射手引用，再加入当前场景。

子弹命中受伤区域后调用其 `take_damage()`，受伤区域再将伤害交给 `HealthComponent`。生命值组件扣血并发出信号，由角色脚本处理受击反馈和死亡。

```text
射击 → Bullet → HurtboxComponent → HealthComponent
                                      ├── damaged → 受击反馈
                                      └── died    → 移除角色
```

子弹遇到射手自身的物理体时会忽略该次碰撞。`area_entered` 回调没有单独排除射手的受伤区域，因此还需要通过碰撞层与掩码避免误伤自己。

## 敌人状态机

`StateMachine` 收集直接子节点中的 `State`，以节点名称的小写形式注册状态，通过 `transitioned` 信号切换状态，并调用对应的进入、退出和更新方法。

```text
Idle（随机漫游）
  └── 距玩家 < 150 → Chase（追击）
                         ├── 距玩家 > 300 → Idle
                         └── 距玩家 < attack_range → Attack（攻击）
                                                       └── 攻击完成 → Chase
```

- **Idle**：随机选择方向，以默认速度 30 移动，每隔 1～3 秒重新选择方向。
- **Chase**：以默认速度 200 接近玩家，默认攻击距离为 50。
- **Attack**：进入状态时对玩家调用一次 `take_damage(10)`，设置敌人朝玩家方向的速度，默认持续 0.5 秒后返回 Chase。

`Attack` 中的参数名为 `knockback_force`，但现有代码实际移动的是敌人，并未对玩家施加击退。

## 文件结构

```text
whitebox-survival/
├── player.gd                      # 玩家移动、瞄准、射击和死亡处理
├── bullet.gd                      # 子弹移动、碰撞和伤害传递
├── enemy.gd                       # 敌人死亡和受击闪白回调
├── health_component.gd            # 生命值与伤害、死亡信号
├── hurtbos_component.gd           # 受伤区域，类名为 HurtboxComponent
├── state.gd                       # 状态基类
├── state_machine.gd               # 状态注册、更新与切换
├── idle.gd                        # 随机漫游和发现玩家
├── chase.gd                       # 追击和攻击距离判断
├── attack.gd                      # 攻击伤害与持续时间
└── README/                        # 开发过程中的学习笔记和图片
```

`hurtbos_component.gd` 是仓库现有文件名，使用时请注意其拼写与类名不同。

## 获取与接入

### 1. 获取源码

```bash
git clone git@github.com:non0422/whitebox-survival.git
cd whitebox-survival
```

也可以使用 HTTPS：

```bash
git clone https://github.com/non0422/whitebox-survival.git
```

### 2. 准备 Godot 工程

代码使用 `CharacterBody2D`、`@export` 和 Godot 4 风格的 API，因此需要 **Godot 4.x**。仓库未记录具体引擎版本，也未提供完整工程配置。

在 Godot 中创建一个 2D 工程，将脚本复制到工程中。补充主场景、玩家、敌人和子弹场景；`player.gd` 预加载的子弹场景必须位于 `res://bullet.tscn`，或自行修改该路径。

### 3. 配置输入

在 **Project → Project Settings → Input Map** 中添加以下动作。代码只定义了动作名称，仓库没有提供实际按键绑定；下表按键为建议配置。

| 动作 | 用途 | 建议绑定 |
| --- | --- | --- |
| `move_left` | 向左移动 | A / 方向左键 |
| `move_right` | 向右移动 | D / 方向右键 |
| `move_up` | 向上移动 | W / 方向上键 |
| `move_down` | 向下移动 | S / 方向下键 |
| `shoot` | 触发射击 | 鼠标左键 |

当前射击使用 `_input(event)` 中的 `is_action_pressed()` 触发，没有实现持续按住自动连发或射速冷却。

### 4. 配置节点与信号

以下为按现有脚本重建场景的建议结构，并非仓库中已有的场景文件：

```text
Main (Node2D)
├── Player (CharacterBody2D, player.gd)
│   ├── CollisionShape2D
│   ├── ColorRect 或 Sprite2D
│   └── HealthComponent (Node, health_component.gd)
└── Enemy (CharacterBody2D, enemy.gd)
    ├── CollisionShape2D
    ├── ColorRect
    ├── HealthComponent (Node, health_component.gd)
    ├── HurtboxComponent (Area2D, hurtbos_component.gd)
    │   └── CollisionShape2D
    └── StateMachine (Node, state_machine.gd)
        ├── Idle (Node, idle.gd)
        ├── Chase (Node, chase.gd)
        └── Attack (Node, attack.gd)

Bullet (Area2D, bullet.gd，单独保存为 bullet.tscn)
└── CollisionShape2D
```

- 玩家脚本通过 `$HealthComponent` 获取生命值组件，敌人脚本通过 `$ColorRect` 获取显示节点，节点名称需与路径一致。
- 为敌人的 `HurtboxComponent.health_component` 指定对应生命值组件。
- 将玩家和敌人的 `HealthComponent.died` 信号连接至各自的 `_on_health_component_died()`；将敌人的 `damaged` 信号连接至 `_on_health_component_damaged()`。
- 将子弹的 `body_entered`、`area_entered` 信号分别连接至脚本中的同名回调。
- 将状态节点命名为 `Idle`、`Chase`、`Attack`，设置 `StateMachine.initial_state` 为 Idle，并为每个状态指定 `enemy` 和 `player` 引用。
- 注意：Idle 的 `player` 导出类型为 `CollisionShape2D`，需要指定玩家的碰撞形状；Chase 和 Attack 的该字段为 `Node2D`，可指定玩家根节点。
- 配置子弹的 Collision Mask，使其能检测敌人的受伤区域；受伤区域的 Collision Layer 必须与之对应。
- 为敌人的 `ColorRect` 设置带有 `flash_modifier` 参数的 ShaderMaterial，才能显示受击闪白效果。

完成场景、资源、节点引用和信号配置后，再设置主场景并运行验证。

## 默认参数

| 参数 | 默认值 | 所在文件 |
| --- | --- | --- |
| 玩家速度 | 300 | `player.gd` |
| 子弹出生偏移 | 40 | `player.gd` |
| 子弹速度 / 伤害 | 600 / 10 | `bullet.gd` |
| 最大生命值 | 100 | `health_component.gd` |
| 漫游速度 / 发现距离 | 30 / 150 | `idle.gd` |
| 追击速度 / 脱离距离 | 200 / 300 | `chase.gd` |
| 攻击距离 | 50 | `chase.gd` |
| 攻击持续时间 / 伤害 | 0.5 秒 / 10 | `attack.gd` |

其中部分参数使用 `@export` 暴露，可在 Inspector 中覆盖。

## 当前限制与后续方向

- 补齐工程配置、场景和材质资源，使仓库可以直接导入运行。
- 子弹尚无超时或超出地图后的回收机制，未命中的子弹会持续存在。
- 玩家死亡后，敌人状态脚本对玩家引用的有效性处理仍需完善。
- 生命值组件尚未加入死亡锁，重复调用伤害方法可能重复发出死亡信号。
- 敌人受击反馈当前每次都会创建 Tween，尚未实现注释中提到的旧动画取消逻辑；实际闪白等待时间为 1 秒。
- 尚未实现刷怪、波次、生存计时、得分和完整的游戏结束流程。

本文根据仓库现有脚本和笔记整理，未完成 Godot 中的运行验证。

## 学习笔记

`README/` 中记录了开发时对输入、坐标、组件和资源加载的理解，部分内容属于探索过程，可能与当前代码不同；阅读时以实际脚本为准。

- [基础理解与开发问题](README/Understand.md)
- [输入处理、碰撞层与伤害组件](README/input.md)
- [子弹、输入和枪口位置的设计思路](README/Train_of_thought.md)
- [preload、load 与 @onready](README/jiazai.md)
- [position 与 global_position](README/positon_or_globalposition.md)

## 许可证

当前仓库未提供 LICENSE 文件，尚未声明开源许可证。
