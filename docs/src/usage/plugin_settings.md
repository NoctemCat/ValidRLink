---
title: ValidRLink Docs | Plugin Settings
description: Plugin Settings
outline: [2, 4]
---

# Plugin Settings

To see them open `Project Settings` and enable `Advanced Settings`
![ValidRLink Settings Location](/images/settings.png)
The settings will be located inside `Addons` group at the end

## Main

### Turn Callables to Buttons

With this on, turns exported `Callables` to buttons

### Call Without Changes Commits Action

Button related setting. With this on, all calls, even without
changes still commits `UndoRedo` action. Commited actions
shows as faint grey text in `Output`. Commiting action also
marks current scene as dirty and in needs of saving

### Call Action Template

Buttons related setting. Allows to specify your own
[format string](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_format_string.html)
for button actions

### Validate Wait Time

Validate uses timer to slighly delay validation, when it tries to validate it
again before the wait time, resets timer. Timer is also stopped as long as left
click is pressed

### Validate Use History

With this on, validate uses editor's history when it flushes values, i.e.
all action can be undone, with some [caveats](./validation). When off,
flushes changes directly, they can't be undone

### Copy Max Depth

The underlying system is relying on recursively copying object's properties.
This setting sets maximum depth it is allowed to copy objects

### Apply Changes to External User Resources

With this on, skips writing changes to buffer when it detect that it tries
to write them to resource stored in `.tres`/`.res` file from outside of
the resource script

### Default Button Path

Path to [`RLinkButton`](./../gdscript/rlink_button), will use its values
for as default for all buttons and `Callable`

## Function Names

### Validate Changes

Will count all these methods as validate method, if empty, no methods will count.
Default values:

- `validate_changes`
- `_validate_changes`
- `ValidateChanges`
- `_ValidateChanges`

### Get RLink Settings

Will count all these methods as methods that return class settings.
Default values:

- `get_rlink_settings`
- `_get_rlink_settings`
- `GetRLinkSettings`
- `_GetRLinkSettings`

## C# Assembly Unload

### Collect GC

Force GC collection on assembly reload

### Execute Pending Continuations

Will call `Dispatcher.SynchronizationContext.ExecutePendingContinuations()` on assembly reload, all
`TaskCanceledException` will be swallowed

### Swallow Base Exception

Makes `ExecutePendingContinuations` continue executing after encountering other exceptions

## Misc

### Duplicate Packed Arrays

Mainly visual thing, without it for some reason the inspector shows incorrect
information if you resized it

### Update Tree on Signal Change

From 4.4 does nothing, before that added temporary node to the scene tree
to force it to update. Without it, showed incorrect information about signals
