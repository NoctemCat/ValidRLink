class_name EditorInnerResource
extends Resource

var set_values := [
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
    Vector4(100.0, 100.0, 100.0, 100.0),
    Vector4i(100, 100, 100, 100),
    Plane(100.0, 100.0, 100.0, 100.0),
    Quaternion.from_euler(Vector3(100.0, 100.0, 100.0)),
    AABB(Vector3(300.0, 300.0, 300.0), Vector3(200.0, 200.0, 200.0)),
    Basis(Vector3(300.0, 300.0, 300.0), Vector3(200.0, 200.0, 200.0), Vector3(100.0, 100.0, 100.0)),
    Transform3D(Vector3(300.0, 300.0, 300.0), Vector3(200.0, 200.0, 200.0), Vector3(100.0, 100.0, 100.0), Vector3(200.0, 200.0, 200.0)),
    Projection(Vector4(200.0, 200.0, 200.0, 200.0), Vector4(300.0, 300.0, 300.0, 300.0), Vector4(400.0, 400.0, 400.0, 100.0), Vector4(100.0, 100.0, 100.0, 100.0)),
    Color(0.3, 0.4, 0.5, 1),
    StringName("new stringname"),
    NodePath("../ValidateInner"),
    {"key1": 100, Vector2i(20, 20): true},
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
]
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
