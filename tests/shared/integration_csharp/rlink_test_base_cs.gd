class_name RLinkTestBaseCSharp
extends GutTest

const SCRIPTS_PATH = "res://tests/integration_csharp/scripts/"

const Context = preload("res://addons/valid_rlink/source/context.gd")
const Settings = Context.Settings
const Compatibility = Context.Compatibility
const ScanResult = preload(Context.RLINK_PATH + "scan_result.gd")
const ScanCache = preload(Context.RLINK_PATH + "scan_cache.gd")
const RLinkMap = preload(Context.RLINK_PATH + "rlink_map.gd")
const RLinkData = preload(Context.RLINK_PATH + "rlink_data.gd")
const RLinkDataCache = preload(Context.RLINK_PATH + "rlink_data_cache.gd")
const ConverterToTool = preload(Context.SOURCE_PATH + "converters/converter_to_tool.gd")
const ConverterToRuntime = preload(Context.SOURCE_PATH + "converters/converter_to_runtime.gd")

var _ctx: Context
var settings: Settings:
    get: return _ctx.settings
var rlink_map: RLinkMap:
    get: return _ctx.rlink_map
var scan_cache: ScanCache:
    get: return _ctx.scan_cache
var rlink_data_cache: RLinkDataCache:
    get: return _ctx.rlink_data_cache
    
#Runs once before all tests
func before_all() -> void:
    _ctx = Context.new()
    _ctx.settings = Settings.new()
    _ctx.compat = Compatibility.new()
    _ctx.undo_redo = null
    _ctx.csharp_enabled = true
    _ctx.csharp_helper_script = load(Context.RUNTIME_PATH + "RLinkCS.cs")
    _ctx.csharp_button_script = load(Context.RUNTIME_PATH + "RLinkButtonCS.cs")
    _ctx.csharp_settings_script = load(Context.RUNTIME_PATH + "RLinkSettingsCS.cs")
    _ctx.csharp_db = load(Context.SOURCE_PATH + "RLinkDB.cs").new()
    add_child(_ctx.csharp_db, true)
    
    _ctx.rlink_map = RLinkMap.new(_ctx)
    _ctx.scan_cache = ScanCache.new(_ctx)
    _ctx.rlink_data_cache = RLinkDataCache.new(_ctx)
    _ctx.converter_to_tool = ConverterToTool.new(_ctx)
    _ctx.converter_to_runtime = ConverterToRuntime.new(_ctx)
    
    
#Runs before each test
func before_each() -> void:
    _ctx.settings.set_default()
    
    
#Runs after each test
func after_each() -> void:
    clear()


#Runs once after all tests
func after_all() -> void:
    _ctx.csharp_db.free()
    _ctx.free()
    

func clear() -> void:
    _ctx.rlink_map.clear()
    _ctx.scan_cache.clear()
    _ctx.rlink_data_cache.clear()


func get_test_name() -> String:
    var path: String = get_script().resource_path
    return path.get_file().get_basename()


func get_cs_script(script_name: String) -> Script:
    return load("%s%s_%s" % [SCRIPTS_PATH, get_test_name(), script_name])

func callables_supported() -> bool:
    return Engine.get_version_info()["hex"] >= 0x040200
