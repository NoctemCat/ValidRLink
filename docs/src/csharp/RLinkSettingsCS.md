---
title: ValidRLink Docs | RLinkSettings
description: Documentation for RLinkSettings
outline: [2, 4]
---

# RLinkSettings

Specifies settings on a class level.
Must be returned from a static method

```csharp
public static RLinkSettingsCS GetRLinkSettings()
{
    var settings = new RLinkSettingsCS();
    settings.Skip = true;
    return settings;
}
```

## Properties

### Skip: `bool`

If true, this class will never get duplicated

---

### SkipProperties: `Godot.Collections.Array<StringName>`

Skips properties mentioned here by their name

---

### AllowedProperties: `Godot.Collections.Array<StringName>`

If not empty, will only allow exported properties mentioned here

---

### ValidateName: `StringName`

Specifies custom validate method name, if not found, doesn't search for default names

---

### MaxDepth: `int`

Custom maximum copy depth, recursively copies objects until max depth is reached

## Methods

### SetSkip()

Sets [`Skip`](#skip-bool) and returns current instance

```csharp
public RLinkSettings SetSkip(bool skip);
```

---

### SetSkipProperties()

Sets [`SkipProperties`](#skipproperties-godot-collections-array-stringname) and returns current instance

```csharp
public RLinkSettingsCS SetSkipProperties(Godot.Collections.Array<StringName> properties);
public RLinkSettingsCS SetSkipProperties(IEnumerable<StringName> properties);
```

---

### AppendSkipProperties()

Appends [`SkipProperties`](#skipproperties-godot-collections-array-stringname) and returns current instance

```csharp
public RLinkSettingsCS AppendSkipProperties(StringName property);
```

---

### SetAllowedProperties()

Sets [`AllowedProperties`](#allowedproperties-godot-collections-array-stringname) and returns current instance

```csharp
public RLinkSettingsCS SetAllowedProperties(Godot.Collections.Array<StringName> properties);
public RLinkSettingsCS SetAllowedProperties(IEnumerable<StringName> properties);
```

---

### AppendAllowedProperties()

Appends [`AllowedProperties`](#allowedproperties-godot-collections-array-stringname) and returns current instance

```csharp
public RLinkSettingsCS AppendAllowedProperties(StringName property);
```

---

### SetValidateName()

Sets [`ValidateName`](#validatename-stringname) and returns current instance

```csharp
public RLinkSettingsCS SetValidateName(StringName name);
```

---

### SetMaxDepth()

Sets [`MaxDepth`](#maxdepth-int) and returns current instance

```csharp
public RLinkSettingsCS SetMaxDepth(int depth);
```
