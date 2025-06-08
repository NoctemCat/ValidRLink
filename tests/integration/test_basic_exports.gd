extends RLinkTestBase


class BasicExports extends Resource:
    static var set_values := [
        true,
        100,
        100.0,
        "new value",
        Vector2(100.0, 100.0),
        Vector2i(100, 100),
        Rect2(100.0, 100.0, 100.0, 100.0),
        Rect2i(100, 100, 100, 100),
        Vector3(100.0, 100.0, 100.0),
        Vector3i(100, 100, 100),
        Transform2D(Vector2(100.0, 100.0), Vector2(200.0, 200.0), Vector2(300.0, 300.0)),
        Vector4(100.0, 100.0, 100.0,100.0),
        Vector4i(100, 100, 100, 100),
        Plane(100.0, 100.0, 100.0, 100.0),
        Quaternion.from_euler(Vector3(100.0, 100.0, 100.0)),
        AABB(Vector3(300.0, 300.0, 300.0), Vector3(200.0, 200.0, 200.0)),
        Basis(Vector3(300.0, 300.0, 300.0), Vector3(200.0, 200.0, 200.0), Vector3(100.0, 100.0, 100.0)),
        Transform3D(Vector3(300.0, 300.0, 300.0), Vector3(200.0, 200.0, 200.0), Vector3(100.0, 100.0, 100.0), Vector3(200.0, 200.0, 200.0)),
        Projection(Vector4(200.0, 200.0, 200.0,200.0), Vector4(300.0, 300.0, 300.0,300.0), Vector4(400.0, 400.0, 400.0,100.0), Vector4(100.0, 100.0, 100.0,100.0)),
        Color(0.3, 0.4, 0.5, 1),
        StringName("new stringname"),
        NodePath("Path/To/Something"),
        { "key1": 100, Vector2i(20, 20): true },
        [Color.WHITE, 200, "text"],
        PackedByteArray([20, 30, 40]),
        PackedInt32Array([1234, 4321, 4544, 1131]),
        PackedInt64Array([1234, 4321, 4544, 1131, 34214, 324, 234]),
        PackedFloat32Array([1234.0, 4321.0, 4544.0, 1131.0]),
        PackedFloat64Array([1234.0, 4321.0, 4544.0, 1131.0, 34214.0, 324.0, 234.0]),
        PackedStringArray(["hello world", "new value", "third"]),
        PackedVector2Array([Vector2(100.0, 100.0), Vector2(200.0, 200.0), Vector2(300.0, 300.0)]),
        PackedVector3Array([Vector3(300.0, 300.0, 300.0), Vector3(200.0, 200.0, 200.0)]),
        PackedColorArray([Color.WHITE, Color.FLORAL_WHITE, Color(0.3, 0.4, 0.5, 1)]),
        PackedVector4Array([Vector4(200.0, 200.0, 200.0,200.0), Vector4(300.0, 300.0, 300.0,300.0), Vector4(400.0, 400.0, 400.0,100.0)]),
    ]
    
    var normal_bool_var: bool
    var normal_int_var: int
    var normal_float_var: float
    var normal_String_var: String
    var normal_Vector2_var: Vector2
    var normal_Vector2i_var: Vector2i
    var normal_Rect2_var: Rect2
    var normal_Rect2i_var: Rect2i
    var normal_Vector3_var: Vector3
    var normal_Vector3i_var: Vector3i
    var normal_Transform2D_var: Transform2D
    var normal_Vector4_var: Vector4
    var normal_Vector4i_var: Vector4i
    var normal_Plane_var: Plane
    var normal_Quaternion_var: Quaternion
    var normal_AABB_var: AABB
    var normal_Basis_var: Basis
    var normal_Transform3D_var: Transform3D
    var normal_Projection_var: Projection
    var normal_Color_var: Color
    var normal_StringName_var: StringName
    var normal_NodePath_var: NodePath
    var normal_Dictionary_var: Dictionary
    var normal_Array_var: Array
    var normal_PackedByteArray_var: PackedByteArray
    var normal_PackedInt32Array_var: PackedInt32Array
    var normal_PackedInt64Array_var: PackedInt64Array
    var normal_PackedFloat32Array_var: PackedFloat32Array
    var normal_PackedFloat64Array_var: PackedFloat64Array
    var normal_PackedStringArray_var: PackedStringArray
    var normal_PackedVector2Array_var: PackedVector2Array
    var normal_PackedVector3Array_var: PackedVector3Array
    var normal_PackedColorArray_var: PackedColorArray
    var normal_PackedVector4Array_var: PackedVector4Array
    @export var export_bool_var: bool
    @export var export_int_var: int
    @export var export_float_var: float
    @export var export_String_var: String
    @export var export_Vector2_var: Vector2
    @export var export_Vector2i_var: Vector2i
    @export var export_Rect2_var: Rect2
    @export var export_Rect2i_var: Rect2i
    @export var export_Vector3_var: Vector3
    @export var export_Vector3i_var: Vector3i
    @export var export_Transform2D_var: Transform2D
    @export var export_Vector4_var: Vector4
    @export var export_Vector4i_var: Vector4i
    @export var export_Plane_var: Plane
    @export var export_Quaternion_var: Quaternion
    @export var export_AABB_var: AABB
    @export var export_Basis_var: Basis
    @export var export_Transform3D_var: Transform3D
    @export var export_Projection_var: Projection
    @export var export_Color_var: Color
    @export var export_StringName_var: StringName
    @export var export_NodePath_var: NodePath
    @export var export_Dictionary_var: Dictionary
    @export var export_Array_var: Array
    @export var export_PackedByteArray_var: PackedByteArray
    @export var export_PackedInt32Array_var: PackedInt32Array
    @export var export_PackedInt64Array_var: PackedInt64Array
    @export var export_PackedFloat32Array_var: PackedFloat32Array
    @export var export_PackedFloat64Array_var: PackedFloat64Array
    @export var export_PackedStringArray_var: PackedStringArray
    @export var export_PackedVector2Array_var: PackedVector2Array
    @export var export_PackedVector3Array_var: PackedVector3Array
    @export var export_PackedColorArray_var: PackedColorArray
    @export var export_PackedVector4Array_var: PackedVector4Array
    
    
    func validate_changes() -> void:
        @warning_ignore("untyped_declaration")
        for value in set_values:
            var type := typeof(value)
            set("normal_%s_var" % type_string(type), value)
            set("export_%s_var" % type_string(type), value)


class OuterNode extends Node:
    @export var res: BasicExports 
    @export var some_var: String
    
    func validate_changes() -> void:
        @warning_ignore("untyped_declaration")
        for value in BasicExports.set_values:
            var type := typeof(value)
            res.set("normal_%s_var" % type_string(type), value)
            res.set("export_%s_var" % type_string(type), value)
        some_var = "after validate"


func test_validate_basic() -> void:
    var test_res := BasicExports.new()
    var data := rlink_data_cache.get_data(test_res)
    _check_default(test_res)
        
    data.validate_changes("test")
    _check_export_set(test_res)
        
    test_res.export_int_var = 1000
    assert_eq(test_res.export_int_var, 1000)
    data.validate_changes("test")
    assert_eq(test_res.export_int_var, 100)


func test_validate_basic_inner() -> void:
    var outer: OuterNode = autofree(OuterNode.new())
    outer.res = BasicExports.new()
    var data := rlink_data_cache.get_data(outer)
    _check_default(outer.res)
    assert_eq(outer.some_var, String())
    
    data.validate_changes("test outer")
    _check_export_set(outer.res)
    assert_eq(outer.some_var, "after validate")
    
    outer.res.normal_Vector2i_var = Vector2i(123, 321)
    outer.res.export_Vector2i_var = Vector2i(321, 123)
    outer.some_var = "set to value"
    assert_eq(outer.res.normal_Vector2i_var, Vector2i(123, 321))
    assert_eq(outer.res.export_Vector2i_var, Vector2i(321, 123))
    assert_eq(outer.some_var, "set to value")
    
    data.validate_changes("test outer")
    assert_eq(outer.res.normal_Vector2i_var, Vector2i(123, 321))
    assert_eq(outer.res.export_Vector2i_var, Vector2i(100, 100))
    assert_eq(outer.some_var, "after validate")
    

func _check_default(basic_export: BasicExports)-> void:
    @warning_ignore("untyped_declaration")
    for value in BasicExports.set_values:
        var type := typeof(value)
        var normal_name: String = "normal_%s_var" % type_string(type)
        var export_name: String = "export_%s_var" % type_string(type)
        
        if basic_export.get(normal_name): fail_test("Value is not default")
        else: pass_test("Contains default value")
        if basic_export.get(export_name): fail_test("Value is not default")
        else: pass_test("Contains default value")


func _check_export_set(basic_export: BasicExports)-> void:
    @warning_ignore("untyped_declaration")
    for value in BasicExports.set_values:
        var type := typeof(value)
        var normal_name: String = "normal_%s_var" % type_string(type)
        var export_name: String = "export_%s_var" % type_string(type)
        
        if basic_export.get(normal_name): fail_test("Value is not default")
        else: pass_test("Contains default value")
        
        if basic_export.get(export_name): pass_test("Exported value is set")
        else: fail_test("Exported value is default after setting")
        assert_eq(basic_export.get(export_name), value)
