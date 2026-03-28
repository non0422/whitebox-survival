属性 参照物 特点
global_position 世界原点 (0,0) 固定参照，永远不变
position 父节点 动态参照，父节点移动它就变

---

图解

```
世界原点 (0,0) ← 固定不变
    │
    │ global_position 都是相对于这里
    │
    └── 火车 (100, 200)  ← 父节点位置会变
            │
            │ position 都是相对于这里
            │
            └── 你 (50, 0)  ← 你在火车里

你的 position = (50, 0)        # 相对于火车
你的 global_position = (150, 200)  # 相对于世界原点

火车移动后 (200, 300)：
你的 position = (50, 0)        # 没变（你还在车厢那个位置）
你的 global_position = (250, 300)  # 变了（火车带你移动了）
```

---

所以

· global_position：绝对坐标，世界原点固定，不管父节点怎么动，它反映真实世界位置
· position：相对坐标，父节点动了，这个值不变，但你在世界中的实际位置变了

---

应用到你的子弹问题

```gdscript
# 先加再设 global_position
get_tree().current_scene.add_child(bullet)  # 子弹的父节点是主场景
bullet.global_position = global_position    # 直接告诉子弹：你去这个世界坐标
```

这样不管主场景在哪，子弹都准确出现在玩家世界位置。

---

一句话总结

global_position = 绝对坐标（世界原点）
position = 相对坐标（爸爸的位置）




意思是世界原点基本就是固定的   global_position就是相对于固定点的位置而言   position就是相对应当前位置来判断   当前位置可能是在世界原点位置移动或者不移动