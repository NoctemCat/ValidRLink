using Godot;
using System;

namespace ValidRLink;

[System.Diagnostics.CodeAnalysis.SuppressMessage("Style", "IDE1006:Naming Styles", Justification = "For ease of getting connected test by name")]
public partial class test_basic_exports_cs_BasicExports : BasicResource
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
    [Export] public StringName ExportStringName { get; set; } = new();
    [Export] public NodePath ExportNodePath { get; set; } = new();
    [Export] public Godot.Collections.Dictionary ExportDictionary { get; set; } = new();
    [Export] public Godot.Collections.Array ExportArray { get; set; } = new();
    [Export] public byte[] ExportPackedByteArray { get; set; }
    [Export] public int[] ExportPackedInt32Array { get; set; }
    [Export] public long[] ExportPackedInt64Array { get; set; }
    [Export] public float[] ExportPackedFloat32Array { get; set; }
    [Export] public double[] ExportPackedFloat64Array { get; set; }
    [Export] public string[] ExportPackedStringArray { get; set; }
    [Export] public Vector2[] ExportPackedVector2Array { get; set; }
    [Export] public Vector3[] ExportPackedVector3Array { get; set; }
    [Export] public Color[] ExportPackedColorArray { get; set; }
    public bool NormalBool { get; set; }
    public int NormalInt { get; set; }
    public float NormalFloat { get; set; }
    public string NormalString { get; set; }
    public Vector2 NormalVector2 { get; set; }
    public Vector2I NormalVector2I { get; set; }
    public Rect2 NormalRect2 { get; set; }
    public Rect2I NormalRect2I { get; set; }
    public Vector3 NormalVector3 { get; set; }
    public Vector3I NormalVector3I { get; set; }
    public Transform2D NormalTransform2D { get; set; }
    public Vector4 NormalVector4 { get; set; }
    public Vector4I NormalVector4I { get; set; }
    public Plane NormalPlane { get; set; }
    public Quaternion NormalQuaternion { get; set; }
    public Aabb NormalAabb { get; set; }
    public Basis NormalBasis { get; set; }
    public Transform3D NormalTransform3D { get; set; }
    public Projection NormalProjection { get; set; }
    public Color NormalColor { get; set; }
    public StringName NormalStringName { get; set; } = new();
    public NodePath NormalNodePath { get; set; } = new();
    public Godot.Collections.Dictionary NormalDictionary { get; set; } = new();
    public Godot.Collections.Array NormalArray { get; set; } = new();
    public byte[] NormalPackedByteArray { get; set; }
    public int[] NormalPackedInt32Array { get; set; }
    public long[] NormalPackedInt64Array { get; set; }
    public float[] NormalPackedFloat32Array { get; set; }
    public double[] NormalPackedFloat64Array { get; set; }
    public string[] NormalPackedStringArray { get; set; }
    public Vector2[] NormalPackedVector2Array { get; set; }
    public Vector3[] NormalPackedVector3Array { get; set; }
    public Color[] NormalPackedColorArray { get; set; }

    public void ValidateChanges()
    {
        foreach (var value in GetValues())
        {
            Set($"Export{value.VariantType}", value);
            Set($"Normal{value.VariantType}", value);
        }
    }
}
