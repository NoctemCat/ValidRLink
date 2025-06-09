using Godot;
using System;

namespace ValidRLink;

public partial class ValidateBasic : Node
{
    [Export] public bool ExportBool { get; set; }
    [Export] public int ExportInt { get; set; }
    [Export] public float ExportFloat { get; set; }
    [Export] public string ExportString { get; set; }
    [Export] public Vector2 ExportVector2 { get; set; }
    [Export] public Vector2I ExportVector2I { get; set; }
    [Export] public Rect2 ExportRect2 { get; set; }
    [Export] public Rect2I ExportRect2I { get; set; }
    [Export] public Vector3 ExportVector3 { get; set; }
    [Export] public Vector3I ExportVector3I { get; set; }
    [Export] public Transform2D ExportTransform2D { get; set; }
    [Export] public Vector4 ExportVector4 { get; set; }
    [Export] public Vector4I ExportVector4I { get; set; }
    [Export] public Plane ExportPlane { get; set; }
    [Export] public Quaternion ExportQuaternion { get; set; }
    [Export] public Aabb ExportAabb { get; set; }
    [Export] public Basis ExportBasis { get; set; }
    [Export] public Transform3D ExportTransform3D { get; set; }
    [Export] public Projection ExportProjection { get; set; }
    [Export] public Color ExportColor { get; set; }
    [Export] public StringName ExportStringName { get; set; }
    [Export] public NodePath ExportNodePath { get; set; }
    [Export] public Godot.Collections.Dictionary ExportDictionary { get; set; }
    [Export] public Godot.Collections.Array ExportArray { get; set; }
    [Export] public byte[] ExportPackedByteArray { get; set; }
    [Export] public int[] ExportPackedInt32Array { get; set; }
    [Export] public long[] ExportPackedInt64Array { get; set; }
    [Export] public float[] ExportPackedFloat32Array { get; set; }
    [Export] public double[] ExportPackedFloat64Array { get; set; }
    [Export] public string[] ExportPackedStringArray { get; set; }
    [Export] public Vector2[] ExportPackedVector2Array { get; set; }
    [Export] public Vector3[] ExportPackedVector3Array { get; set; }
    [Export] public Color[] ExportPackedColorArray { get; set; }
    [Export] public Vector4[] ExportPackedVector4Array { get; set; }


    public void ValidateChanges()
    {
        foreach (var value in GetValues())
        {
            Set($"Export{value.VariantType}", value);
        }
    }

    private static Godot.Collections.Array GetValues()
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
}
