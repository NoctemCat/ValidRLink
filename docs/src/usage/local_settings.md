---
title: ValidRLink Docs | Local Settings
description: Local Settings
outline: [2, 4]
---

# Local Settings

It is possible to specify some settings on a class level
using [`RLinkSettings`](./../gdscript/rlink_settings). You can
return [`RLinkSettings`](./../gdscript/rlink_settings) or `Dictionary`
from static method with the name specified in
[plugin settings](./plugin_settings#get-rlink-settings)

::: code-group

```gdscript [RLinkSettings]
static func get_rlink_settings() -> RLinkSettings:
    var settings := RLinkSettings.new()
    settings.skip = true
    return settings
```

```gdscript [Dictionary]
static func get_rlink_settings() -> Dictionary:
    return { skip= true }
```

```csharp [RLinkSettingsCS]
public static RLinkSettingsCS GetRLinkSettings()
{
    var settings = new RLinkSettingsCS();
    settings.Skip = true;
    return settings;
}
```

```csharp [C# Dictionary]
public static Dictionary<string, Variant> GetRLinkSettings()
{
    return new() { ["skip"] = true };
}
```

:::

## Filter Properties

You can use [`skip_properties`](./../gdscript/rlink_settings#skip-properties-array-stringname)
and [`allowed_properties`](./../gdscript/rlink_settings#allowed-properties-array-stringname)
to filter properties by their name
