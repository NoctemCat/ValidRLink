

using System;
using Godot;


namespace ValidRLink;

public partial class BasicNode : Node
{
    public static string GetTypeString(Variant.Type type)
    {
        return type.ToString();
    }

    public static Godot.Collections.Array GetValues()
    {
        return [
            true,
            100,
            100.0,
            "new value",
            new Vector2(100.0f, 100.0f),
            new Vector2I(100, 100),
            new Rect2(100.0f, 100.0f, 100.0f, 100.0f),
            new Rect2I(100, 100, 100, 100),
            new Vector3(100.0f, 100.0f, 100.0f),
            new Vector3I(100, 100, 100),
            new Transform2D(new(100.0f, 100.0f), new(200.0f, 200.0f), new(300.0f, 300.0f)),
            new Vector4(100.0f, 100.0f, 100.0f,100.0f),
            new Vector4I(100, 100, 100, 100),
            new Plane(100.0f, 100.0f, 100.0f, 100.0f),
            Quaternion.FromEuler(new(100.0f, 0.0f, 0.0f)),
            new Aabb(new(300.0f, 300.0f, 300.0f), new(200.0f, 200.0f, 200.0f)),
            new Basis(new(300.0f, 300.0f, 300.0f), new(200.0f, 200.0f, 200.0f), new(100.0f, 100.0f, 100.0f)),
            new Transform3D(new(300.0f, 300.0f, 300.0f), new(200.0f, 200.0f, 200.0f), new(100.0f, 100.0f, 100.0f), new(200.0f, 200.0f, 200.0f)),
            new Projection(new(200.0f, 200.0f, 200.0f,200.0f), new(300.0f, 300.0f, 300.0f,300.0f), new(400.0f, 400.0f, 400.0f,100.0f), new(100.0f, 100.0f, 100.0f,100.0f)),
            new Color(0.3f, 0.4f, 0.5f, 1),
            new StringName("new stringname"),
            new NodePath("../ValidateInner"),
            new Godot.Collections.Dictionary { {"key1", 100}, {new Vector2I(20, 20), true} },
            new Godot.Collections.Array {Colors.White, 200, "text" },
            new byte [] { 20, 30, 40},
            new int [] { 1234, 4321, 4544, 1131},
            new long [] { 1234, 4321, 4544, 1131, 34214, 324, 234},
            new float [] { 1234.0f, 4321.0f, 4544.0f, 1131.0f},
            new double [] { 1234.0, 4321.0, 4544.0, 1131.0, 34214.0, 324.0, 234.0},
            new string[] {"hello world", "new value", "third"},
            new Vector2[] {new(100.0f, 100.0f), new(200.0f, 200.0f), new(300.0f, 300.0f)},
            new Vector3[] {new(300.0f, 300.0f, 300.0f), new(200.0f, 200.0f, 200.0f)},
            new Color[] {Colors.White, Colors.Wheat, Colors.FloralWhite, new(0.3f, 0.4f, 0.5f, 1)},
            new Vector4[] {new(200.0f, 200.0f, 200.0f,200.0f), new(300.0f, 300.0f, 300.0f,300.0f), new(400.0f, 400.0f, 400.0f,100.0f)} ,
        ];
    }


    public static Variant GetDefault(Variant.Type type)
    {
        return type switch
        {
            Variant.Type.Nil => NullVariant(),
            Variant.Type.Bool => default(bool),
            Variant.Type.Int => default(int),
            Variant.Type.Float => default(float),
            Variant.Type.String => "",
            Variant.Type.Vector2 => default(Vector2),
            Variant.Type.Vector2I => default(Vector2I),
            Variant.Type.Rect2 => default(Rect2),
            Variant.Type.Rect2I => default(Rect2I),
            Variant.Type.Vector3 => default(Vector3),
            Variant.Type.Vector3I => default(Vector3I),
            Variant.Type.Transform2D => default(Transform2D),
            Variant.Type.Vector4 => default(Vector4),
            Variant.Type.Vector4I => default(Vector4I),
            Variant.Type.Plane => default(Plane),
            Variant.Type.Quaternion => default(Quaternion),
            Variant.Type.Aabb => default(Aabb),
            Variant.Type.Basis => default(Basis),
            Variant.Type.Transform3D => default(Transform3D),
            Variant.Type.Projection => default(Projection),
            Variant.Type.Color => default(Color),
            Variant.Type.StringName => new StringName(),
            Variant.Type.NodePath => new NodePath(),
            Variant.Type.Rid => default(Rid),
            Variant.Type.Object => new Variant(),
            Variant.Type.Callable => default(Callable),
            Variant.Type.Signal => default(Signal),
            Variant.Type.Dictionary => new Godot.Collections.Dictionary(),
            Variant.Type.Array => new Godot.Collections.Array(),
            Variant.Type.PackedByteArray => Array.Empty<byte>(),
            Variant.Type.PackedInt32Array => Array.Empty<int>(),
            Variant.Type.PackedInt64Array => Array.Empty<long>(),
            Variant.Type.PackedFloat32Array => Array.Empty<float>(),
            Variant.Type.PackedFloat64Array => Array.Empty<double>(),
            Variant.Type.PackedStringArray => Array.Empty<string>(),
            Variant.Type.PackedVector2Array => Array.Empty<Vector2>(),
            Variant.Type.PackedVector3Array => Array.Empty<Vector3>(),
            Variant.Type.PackedColorArray => Array.Empty<Color>(),
            Variant.Type.PackedVector4Array => Array.Empty<Vector4>(),
            _ => NullVariant(),
        };

        static Variant NullVariant() => new();
    }

}