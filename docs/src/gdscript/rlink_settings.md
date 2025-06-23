---
title: ValidRLink Docs | RLinkSettings
description: Documentation for RLinkSettings
outline: [2, 4]
---

# RLinkSettings

Specifies settings on a class level.
Must be returned from a static method

```gdscript
static func get_rlink_settings() -> RLinkSettings:
    var settings := RLinkSettings.new()
    settings.skip = true
    return settings
```

## Properties

### skip: `bool`

If true, this class will never get duplicated

---

### skip_properties: `Array[StringName]`

Skips properties mentioned here by their name

---

### allowed_properties: `Array[StringName]`

If not empty, will only allow exported properties mentioned here

---

### validate_name: `StringName`

Specifies custom validate method name, if not found, doesn't search for default names

---

### max_depth: `int`

Custom maximum copy depth, recursively copies objects until max depth is reached

## Methods

### set_skip()

Sets [`skip`](#skip-bool) and returns current instance

```gdscript
func set_skip(is_skipped: bool) -> RLinkSettings
```

---

### set_skip_properties()

Sets [`skip_properties`](#skip-properties-array-stringname) and returns current instance

```gdscript
func set_skip_properties(properties: Array[StringName]) -> RLinkSettings
```

---

### append_skip_properties()

Appends [`skip_properties`](#skip-properties-array-stringname) and returns current instance

```gdscript
func append_skip_properties(property: StringName) -> RLinkSettings
```

---

### set_allowed_properties()

Sets [`allowed_properties`](#allowed-properties-array-stringname) and returns current instance

```gdscript
func set_allowed_properties(properties: Array[StringName]) -> RLinkSettings
```

---

### append_allowed_properties()

Appends [`allowed_properties`](#allowed-properties-array-stringname) and returns current instance

```gdscript
func append_allowed_properties(properties: Array[StringName]) -> RLinkSettings
```

---

### set_validate_name()

Sets [`validate_name`](#validate-name-stringname) and returns current instance

```gdscript
func set_validate_name(name: StringName) -> RLinkSettings
```

---

### set_max_depth()

Sets [`max_depth`](#max-depth-int) and returns current instance

```gdscript
func set_max_depth(depth: int) -> RLinkSettings
```
