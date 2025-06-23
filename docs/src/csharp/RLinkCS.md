---
title: ValidRLink Docs | RLinkCS
description: Documentation for RLinkCS
outline: [2, 4]
---

# RLinkCS

Adds common operations with history support. Any changes to
[`placeholder`](#placeholder-Object) directly won't be included in editor history

## Properties

### Placeholder: `GodotObject?`

The current placeholder object

## Methods

### GetTree()

Returns current tree

```csharp
public SceneTree GetTree();
```

---

### IsEditedSceneRoot()

Compares current node with `EditedSceneRoot`

```csharp
public bool IsEditedSceneRoot();
```

---

### GetToolFrom()

Retrieves tool object if exist, if it doesn't returns null

```csharp
public GodotObject? GetToolFrom(GodotObject runtime);
public T? GetToolFrom<T>(GodotObject runtime) where T : GodotObject;
```

---

### GetRuntimeFrom()

Retrieves placeholder object if exist, if it doesn't returns null

```csharp
public GodotObject? GetRuntimeFrom(GodotObject tool);
public T? GetRuntimeFrom<T>(GodotObject tool) where T : GodotObject;
```

---

### ConvertToTool()

Converts placeholder to a tool object

```csharp
public GodotObject? ConvertToTool(GodotObject? runtime, int customDepth = 1);
[return: NotNullIfNotNull(nameof(runtime))]
public T? ConvertToTool<T>(GodotObject? runtime, int customDepth = 1) where T : GodotObject;
```

---

### ConvertToRuntime()

Converts tool object to placeholder

```csharp
public GodotObject? ConvertToRuntime(GodotObject? tool, int customDepth = 1, bool trackInstances = true);
[return: NotNullIfNotNull(nameof(tool))]
public T? ConvertToRuntime<T>(GodotObject? tool, int customDepth = 1, bool trackInstances = true) where T : GodotObject;
```

---

### IsPairInvalid()

Check if the registered pair is invalid. For runtime nodes being outside of tree counts as invalid

```csharp
public bool IsPairInvalid(GodotObject obj, bool deleteIfInvalid = true);
```

---

### IsPairValid()

Check if the registered pair is valid. For runtime nodes being outside of tree counts as invalid

```csharp
public bool IsPairValid(GodotObject obj, bool deleteIfInvalid = true);
```

---

### InstantiateFile()

Instantiates scene and converts root node to real type

```csharp
public Node InstantiateFile(string path);
public T InstantiateFile<T>(string path) where T : Node;
```

---

### InstantiatePacked()

Instantiates scene and converts root node to real type

```csharp
public Node InstantiatePacked(PackedScene scene);
public T InstantiatePacked<T>(PackedScene scene) where T : Node;
```

---

### GetParent()

Gets parent as real type

```csharp
public Node? GetParent();
public T? GetParent<T>() where T : Node;
```

---

### GetParentFor()

Gets parent for node as real type

```csharp
public Node? GetParentFor(Node toolNode);
public T? GetParentFor<T>(Node toolNode) where T : Node;
```

---

### GetNodeOrNull()

Gets node as real type from current

```csharp
public Node? GetNodeOrNull(in NodePath path);
public T? GetNodeOrNull<T>(in NodePath path) where T : Node;
```

---

### GetNodeOrNullFrom()

Gets node from node as real type

```csharp
public Node? GetNodeOrNullFrom(Node toolNode, in NodePath path);
public T? GetNodeOrNullFrom<T>(Node toolNode, in NodePath path) where T : Node;
```

---

### HasNode()

Checks if node exist

```csharp
public bool HasNode(in NodePath path);
```

---

### HasNodeFrom()

Checks if node exist from node

```csharp
public bool HasNodeFrom(Node toolNode, in NodePath path);
```

---

### AddChild()

Adds child to current node

```csharp
public void AddChild(Node child);
```

---

### AddChildTo()

Adds child to `toolNode` node

```csharp
public void AddChildTo(Node toolNode, Node child);
```

---

### AddChildPath()

Gets the node before last segment and adds a child to it with the name from the last segment
When the last parameter is true, frees passed `child` if node before last segment  
from `path` is not found

```csharp
public void AddChildPath(NodePath path, Node child, bool freeIfNotFound = true);
```

---

### RemoveChild()

Removes child from current node

```csharp
public void RemoveChild(Node child);
```

---

### RemoveChildFrom()

Removes child from node

```csharp
public void RemoveChildFrom(Node toolNode, Node child);
```

---

### RemoveChildPath()

Removes the node at the end of the path from current

```csharp
public void RemoveChildPath(in NodePath path);
```

---

### RemoveAllChildren()

Removes all children from current node

```csharp
public void RemoveAllChildren();
```

---

### RemoveAllChildrenFrom()

Removes all children from `toolNode`

```csharp
public void RemoveAllChildrenFrom(Node toolNode);
```

---

### RemoveAllChildrenPath()

Removes all children from the node at path

```csharp
public void RemoveAllChildrenPath(in NodePath path);
```

---

### SignalConnect()

Connects them persistingly, bound arguments get added first, then unbind. Callables are treated as connected if
they have the same object and method, so different binds are treated as the same callable
::: warning
The conversion from `Delegate` to `Callable` is very strict, every type in parameters and return must be
[Variant compatible](https://docs.godotengine.org/en/stable/tutorials/scripting/c_sharp/c_sharp_variant.html#variant-compatible-types).
Doesn't support static methods
:::

```csharp
public void SignalConnect(in Signal signal, Delegate callable, Godot.Collections.Array? bindvArgs = null, int unbind = 0);
public void SignalConnect(in Signal signal, in Variant callable, Godot.Collections.Array? bindvArgs = null, int unbind = 0);
```

---

### SignalDisconnect()

Disconnects them, bound arguments get added first, then unbind. Callables are treated as connected if
they have the same object and method, so different binds are treated as the same callable
::: warning
The conversion from `Delegate` to `Callable` is very strict, every type in parameters and return must be
[Variant compatible](https://docs.godotengine.org/en/stable/tutorials/scripting/c_sharp/c_sharp_variant.html#variant-compatible-types).
Doesn't support static methods
:::

```csharp
public void SignalDisconnect(in Signal signal, Delegate method, Godot.Collections.Array? bindvArgs = null, int unbind = 0);
public void SignalDisconnect(in Signal signal, in Variant callable, Godot.Collections.Array? bindvArgs = null, int unbind = 0);
```

---

### SignalIsConnected()

Check if callable connected to the signal. Callables are treated as connected if
they have the same object and method, so different binds are treated as the same callable
::: warning
The conversion from `Delegate` to `Callable` is very strict, every type in parameters and return must be
[Variant compatible](https://docs.godotengine.org/en/stable/tutorials/scripting/c_sharp/c_sharp_variant.html#variant-compatible-types).
Doesn't support static methods
:::

```csharp
public bool SignalIsConnected(in Signal signal, Delegate method, Godot.Collections.Array? bindvArgs = null, int unbind = 0);
public bool SignalIsConnected(in Signal signal, in Variant callable, Godot.Collections.Array? bindvArgs = null, int unbind = 0);
```

---

### SignalToggle()

Checks if connected, if connected disconnects callable, if not callable is connected

```csharp
public void SignalToggle(in Signal signal, Delegate method, Godot.Collections.Array? bindvArgs = null, int unbind = 0);
public void SignalToggle(in Signal signal, in Variant callable, Godot.Collections.Array? bindvArgs = null, int unbind = 0);
```

---

### AddChanges()

The added changes will be added to buffer and added to history. In the case of checked
call, if the check fails, all changes gets discarded

```csharp
public void AddChanges(GodotObject obj, StringName property, Variant? oldValue, Variant? newValue);
```

---

### AddDoMethod()

Only works with native resources. Other objects get duplicated, so they are alive only
for a limited time, so general do methods for them won't be supported

```csharp
public void AddDoMethod(GodotObject obj, StringName property, Godot.Collections.Array? args = null);
```

---

### AddUndoMethod()

Only works with native resources. Other objects get duplicated, so they are alive only
for a limited time, so general do methods for them won't be supported

```csharp
public void AddUndoMethod(GodotObject obj, StringName property, Godot.Collections.Array? args = null);
```
