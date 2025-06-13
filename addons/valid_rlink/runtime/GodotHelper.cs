#nullable enable

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Diagnostics.CodeAnalysis;
using System.Linq;
using System.Reflection;
using System.Threading.Tasks;
using Godot;
using Godot.NativeInterop;

#pragma warning disable IDE0130 // Namespace does not match folder structure
namespace ValidRLink;
#pragma warning restore IDE0130 // Namespace does not match folder structure

public static class GodotHelper
{
    private static readonly StringName completedName = "completed";

    /// <summary>
    /// Calls awaitable GDScript method as async
    /// </summary>
    /// <returns>The task waiting for a result, or a result</returns>
    public static async Task<Variant> CallvAsync(GodotObject obj, StringName method, Godot.Collections.Array args)
    {
        Variant result = obj.Callv(method, args);
        if (IsVariantRefCounted(result, out RefCounted? refCounted))
        {
            if (refCounted.GetClass() == "GDScriptFunctionState")
            {
                using (result)
                using (refCounted)
                {
                    return (await refCounted.ToSignal(refCounted, completedName))[0];
                }
            }
            else
            {
                refCounted.Dispose();
            }
        }
        return result;
    }

    /// <summary>
    /// Tries to convert base object to Variant
    /// </summary>
    /// <returns>True if successfully converted to Variant</returns>
    public static bool TryToVariant(object? value, out Variant variant)
    {
        if (value is Variant variantValue)
        {
            variant = variantValue;
            return true;
        }
        if (value is not null)
        {
            Type valueType = value.GetType();
            switch (Type.GetTypeCode(valueType))
            {
                case TypeCode.Boolean:
                    {
                        variant = (bool)value;
                        return true;
                    }
                case TypeCode.Char:
                    {
                        variant = (char)value;
                        return true;
                    }
                case TypeCode.SByte:
                    {
                        variant = (sbyte)value;
                        return true;
                    }
                case TypeCode.Int16:
                    {
                        variant = (short)value;
                        return true;
                    }
                case TypeCode.Int32:
                    {
                        variant = (int)value;
                        return true;
                    }
                case TypeCode.Int64:
                    {
                        variant = (long)value;
                        return true;
                    }
                case TypeCode.Byte:
                    {
                        variant = (byte)value;
                        return true;
                    }
                case TypeCode.UInt16:
                    {
                        variant = (ushort)value;
                        return true;
                    }
                case TypeCode.UInt32:
                    {
                        variant = (uint)value;
                        return true;
                    }
                case TypeCode.UInt64:
                    {
                        variant = (ulong)value;
                        return true;
                    }
                case TypeCode.Single:
                    {
                        variant = (float)value;
                        return true;
                    }
                case TypeCode.Double:
                    {
                        variant = (double)value;
                        return true;
                    }
                case TypeCode.String:
                    {
                        variant = (string)value;
                        return true;
                    }
                default:
                    {
                        if (valueType == typeof(Vector2))
                        {
                            variant = (Vector2)value;
                            return true;
                        }
                        if (valueType == typeof(Vector2I))
                        {
                            variant = (Vector2I)value;
                            return true;
                        }
                        if (valueType == typeof(Rect2))
                        {
                            variant = (Rect2)value;
                            return true;
                        }
                        if (valueType == typeof(Rect2I))
                        {
                            variant = (Rect2I)value;
                            return true;
                        }
                        if (valueType == typeof(Transform2D))
                        {
                            variant = (Transform2D)value;
                            return true;
                        }
                        if (valueType == typeof(Vector3))
                        {
                            variant = (Vector3)value;
                            return true;
                        }
                        if (valueType == typeof(Vector3I))
                        {
                            variant = (Vector3I)value;
                            return true;
                        }
                        if (valueType == typeof(Vector4))
                        {
                            variant = (Vector4)value;
                            return true;
                        }
                        if (valueType == typeof(Vector4I))
                        {
                            variant = (Vector4I)value;
                            return true;
                        }
                        if (valueType == typeof(Basis))
                        {
                            variant = (Basis)value;
                            return true;
                        }
                        if (valueType == typeof(Quaternion))
                        {
                            variant = (Quaternion)value;
                            return true;
                        }
                        if (valueType == typeof(Transform3D))
                        {
                            variant = (Transform3D)value;
                            return true;
                        }
                        if (valueType == typeof(Projection))
                        {
                            variant = (Projection)value;
                            return true;
                        }
                        if (valueType == typeof(Aabb))
                        {
                            variant = (Aabb)value;
                            return true;
                        }
                        if (valueType == typeof(Color))
                        {
                            variant = (Color)value;
                            return true;
                        }
                        if (valueType == typeof(Plane))
                        {
                            variant = (Plane)value;
                            return true;
                        }
                        if (valueType == typeof(Godot.Callable))
                        {
                            variant = (Godot.Callable)value;
                            return true;
                        }
                        if (valueType == typeof(Signal))
                        {
                            variant = (Signal)value;
                            return true;
                        }
                        if (valueType.IsEnum)
                        {
                            variant = (ulong)value;
                            return true;
                        }
                        if (valueType.IsArray || valueType.IsSZArray)
                        {
                            if (valueType == typeof(byte[]))
                            {
                                variant = (byte[])value;
                                return true;
                            }
                            if (valueType == typeof(int[]))
                            {
                                variant = (int[])value;
                                return true;
                            }
                            if (valueType == typeof(long[]))
                            {
                                variant = (long[])value;
                                return true;
                            }
                            if (valueType == typeof(float[]))
                            {
                                variant = (float[])value;
                                return true;
                            }
                            if (valueType == typeof(double[]))
                            {
                                variant = (double[])value;
                                return true;
                            }
                            if (valueType == typeof(string[]))
                            {
                                variant = (string[])value;
                                return true;
                            }
                            if (valueType == typeof(Vector2[]))
                            {
                                variant = (Vector2[])value;
                                return true;
                            }
                            if (valueType == typeof(Vector3[]))
                            {
                                variant = (Vector3[])value;
                                return true;
                            }
                            if (valueType == typeof(Vector4[]))
                            {
                                variant = (Vector4[])value;
                                return true;
                            }
                            if (valueType == typeof(Color[]))
                            {
                                variant = (Color[])value;
                                return true;
                            }
                            if (valueType == typeof(StringName[]))
                            {
                                variant = (StringName[])value;
                                return true;
                            }
                            if (valueType == typeof(NodePath[]))
                            {
                                variant = (NodePath[])value;
                                return true;
                            }
                            if (valueType == typeof(Rid[]))
                            {
                                variant = (Rid[])value;
                                return true;
                            }
                            if (typeof(GodotObject[]).IsAssignableFrom(valueType))
                            {
                                variant = (GodotObject[])value;
                                return true;
                            }
                        }
                        else if (valueType.IsGenericType)
                        {
                            if (typeof(GodotObject).IsAssignableFrom(valueType))
                            {
                                variant = (GodotObject)value;
                                return true;
                            }
                            var dictInterface = Type.GetType("Godot.Collections.IGenericGodotDictionary, GodotSharp, Culture=neutral, PublicKeyToken=null");
                            if (dictInterface?.IsAssignableFrom(valueType) ?? false)
                            {
                                var dictProp = dictInterface.GetProperty("UnderlyingDictionary");
                                variant = (Godot.Collections.Dictionary)dictProp!.GetValue(value, null)!;
                                return true;
                            }
                            var arrayInterface = Type.GetType("Godot.Collections.IGenericGodotArray, GodotSharp, Culture=neutral, PublicKeyToken=null");
                            if (arrayInterface?.IsAssignableFrom(valueType) ?? false)
                            {
                                var arrayProp = arrayInterface.GetProperty("UnderlyingArray");
                                variant = (Godot.Collections.Dictionary)arrayProp!.GetValue(value, null)!;
                                return true;
                            }
                        }
                        if (typeof(Variant) == valueType)
                        {
                            variant = (Variant)value;
                            return true;
                        }
                        if (typeof(GodotObject).IsAssignableFrom(valueType))
                        {
                            variant = (GodotObject)value;
                            return true;
                        }
                        if (typeof(StringName) == valueType)
                        {
                            variant = (StringName)value;
                            return true;
                        }
                        if (typeof(NodePath) == valueType)
                        {
                            variant = (NodePath)value;
                            return true;
                        }
                        if (typeof(Rid) == valueType)
                        {
                            variant = (Rid)value;
                            return true;
                        }
                        if (typeof(Godot.Collections.Dictionary) == valueType)
                        {
                            variant = (Godot.Collections.Dictionary)value;
                            return true;
                        }
                        if (typeof(Godot.Collections.Array) == valueType)
                        {
                            variant = (Godot.Collections.Array)value;
                            return true;
                        }
                        break;
                    }
            }
        }
        variant = new Variant();
        return false;
    }

    /// <summary>
    /// Extracts the value from Variant to object
    /// </summary>
    /// <returns>Value as object</returns>
    public static object? ToObject(scoped in Variant variant)
    {
        return variant.VariantType switch
        {
            Variant.Type.Nil => null,
            Variant.Type.Bool => variant.AsBool(),
            Variant.Type.Int => variant.AsInt64(),
            Variant.Type.Float => variant.AsDouble(),
            Variant.Type.String => variant.AsString(),
            Variant.Type.Vector2 => variant.AsVector2(),
            Variant.Type.Vector2I => variant.AsVector2I(),
            Variant.Type.Rect2 => variant.AsRect2(),
            Variant.Type.Rect2I => variant.AsRect2I(),
            Variant.Type.Vector3 => variant.AsVector3(),
            Variant.Type.Vector3I => variant.AsVector3I(),
            Variant.Type.Transform2D => variant.AsTransform2D(),
            Variant.Type.Vector4 => variant.AsVector4(),
            Variant.Type.Vector4I => variant.AsVector4I(),
            Variant.Type.Plane => variant.AsPlane(),
            Variant.Type.Quaternion => variant.AsQuaternion(),
            Variant.Type.Aabb => variant.AsAabb(),
            Variant.Type.Basis => variant.AsBasis(),
            Variant.Type.Transform3D => variant.AsTransform3D(),
            Variant.Type.Projection => variant.AsProjection(),
            Variant.Type.Color => variant.AsColor(),
            Variant.Type.StringName => variant.AsStringName(),
            Variant.Type.NodePath => variant.AsNodePath(),
            Variant.Type.Rid => variant.AsRid(),
            Variant.Type.Object => variant.AsGodotObject(),
            Variant.Type.Callable => variant.AsCallable(),
            Variant.Type.Signal => variant.AsSignal(),
            Variant.Type.Dictionary => variant.AsGodotDictionary(),
            Variant.Type.Array => variant.AsGodotArray(),
            Variant.Type.PackedByteArray => variant.AsByteArray(),
            Variant.Type.PackedInt32Array => variant.AsInt32Array(),
            Variant.Type.PackedInt64Array => variant.AsInt64Array(),
            Variant.Type.PackedFloat32Array => variant.AsFloat32Array(),
            Variant.Type.PackedFloat64Array => variant.AsFloat64Array(),
            Variant.Type.PackedStringArray => variant.AsStringArray(),
            Variant.Type.PackedVector2Array => variant.AsVector2Array(),
            Variant.Type.PackedVector3Array => variant.AsVector3Array(),
            Variant.Type.PackedColorArray => variant.AsColorArray(),
            Variant.Type.PackedVector4Array => variant.AsVector4Array(),
            _ => null,
        };
    }

    /// <summary>
    /// Checks and cast Variant to RefCounted
    /// </summary>
    public static bool IsVariantRefCounted(scoped in Variant variant, [NotNullWhen(true)] out RefCounted? refCounted)
    {
        if (variant.VariantType == Variant.Type.Object && variant.AsGodotObject() is RefCounted refCountedConv)
        {
            refCounted = refCountedConv;
            return true;
        }
        refCounted = null;
        return false;
    }

    /// <summary>
    /// Enumerates properties with Storage and ScriptVariable flags
    /// </summary>
    public static IEnumerable<string> GetObjectProperties(GodotObject obj)
    {
        PropertyUsageFlags storedScrtiptVar = PropertyUsageFlags.Storage | PropertyUsageFlags.ScriptVariable;
        foreach (var property in obj.GetPropertyList())
        {
            if ((property["usage"].As<PropertyUsageFlags>() & storedScrtiptVar) == storedScrtiptVar)
            {
                yield return property["name"].AsString();
            }
        }
    }

    /// <summary>
    /// Replicates Get from GDScript dictionary
    /// </summary>
    /// <returns>The value if key exist or default</returns>
    public static Variant GetDefault(IDictionary<Variant, Variant> dictionary, scoped in Variant key, scoped in Variant defaultValue)
    {
        if (dictionary.TryGetValue(key, out Variant value))
        {
            return value;
        }
        return defaultValue;
    }

    /// <summary>
    /// Helper class to extract info from Callable
    /// </summary>
    public static class Callable
    {
        private static Expression CallableConstructor { get; }
        public static bool UnboundCountAvailable { get; }
        private static Expression? GetUnboundCountExpr { get; }
        private static Expression CallableIsValid { get; }
        private static Expression CallableGetBoundArguments { get; }
        private static Expression CallableGetMethod { get; }
        private static Expression CallableBind { get; }
        private static Expression CallableBindv { get; }
        private static Expression CallableUnbind { get; }
        private static Expression CallableCallEmpty { get; }
        private static Expression CallableCall { get; }


        static Callable()
        {
            long version = Engine.Singleton.GetVersionInfo()["hex"].AsInt64();
            CallableConstructor = new();
            CallableConstructor.Parse("Callable(variant, method)", ["variant", "method"]);
            UnboundCountAvailable = version >= 0x040400;
            if (UnboundCountAvailable)
            {
                GetUnboundCountExpr = new();
                GetUnboundCountExpr.Parse("callable.get_unbound_arguments_count()", ["callable"]);
            }
            CallableIsValid = new();
            CallableIsValid.Parse("callable.is_valid()", ["callable"]);
            CallableGetBoundArguments = new();
            CallableGetBoundArguments.Parse("callable.get_bound_arguments()", ["callable"]);
            CallableGetMethod = new();
            CallableGetMethod.Parse("callable.get_method()", ["callable"]);
            CallableBind = new();
            CallableBind.Parse("callable.bind(argument)", ["callable", "argument"]);
            CallableBindv = new();
            CallableBindv.Parse("callable.bindv(arguments)", ["callable", "arguments"]);
            CallableUnbind = new();
            CallableUnbind.Parse("callable.unbind(argcount)", ["callable", "argcount"]);
            CallableCallEmpty = new();
            CallableCallEmpty.Parse("callable.call()", ["callable"]);
            CallableCall = new();
            CallableCall.Parse("callable.call(argument)", ["callable", "argument"]);
        }

        /// <summary>
        /// Calls GDScript's constructor, was needed for Callable to static method. Still doesn't return valid Callable :/
        /// </summary>
        /// <returns>Callable as variant</returns>
        public static Variant CallConstructor(Variant godotObject, StringName method)
        {
            return CallableConstructor.Execute([godotObject, method]);
        }

        public static bool IsValid(scoped in Variant callable) => CallableIsValid.Execute([callable]).AsBool();
        public static bool IsValid(scoped in Godot.Callable callable) => CallableIsValid.Execute([callable]).AsBool();

        public static int GetUnboundArgumentsCount(scoped in Variant callable)
             => GetUnboundCountExpr?.Execute([callable]).AsInt32() ?? 0;
        public static int GetUnboundArgumentsCount(scoped in Godot.Callable callable)
             => GetUnboundCountExpr?.Execute([callable]).AsInt32() ?? 0;

        public static Godot.Collections.Array GetBoundArguments(scoped in Variant callable)
            => CallableGetBoundArguments.Execute([callable]).AsGodotArray();
        public static Godot.Collections.Array GetBoundArguments(scoped in Godot.Callable callable)
            => CallableGetBoundArguments.Execute([callable]).AsGodotArray();

        public static StringName GetMethod(scoped in Variant callable) => CallableGetMethod.Execute([callable]).AsStringName();
        public static StringName GetMethod(scoped in Godot.Callable callable) => CallableGetMethod.Execute([callable]).AsStringName();

        /// <summary>
        /// Binds variant argument to callable, casting returned callable is invalid, ConvertCallableToManaged doesn't take into 
        /// account native GDScript callables
        /// </summary>
        /// <returns>
        /// Copy with argument bound, converting it into Callable will make it invalid, call it with `Call`
        /// from this class or pass to Godot as Variant through `Call` on the GodotObject class
        /// </returns>
        public static Variant Bind(scoped in Godot.Callable callable, scoped in Variant arg) => CallableBind.Execute([callable, arg]);
        /// <inheritdoc cref="Bind(in Godot.Callable, in Variant)" />
        public static Variant Bind(scoped in Variant callable, scoped in Variant arg) => CallableBind.Execute([callable, arg]);

        /// <summary>
        /// Binds variant argument to callable, casting returned callable is invalid, ConvertCallableToManaged doesn't take into 
        /// account native GDScript callables
        /// </summary>
        /// <returns>
        /// Copy with arguments bound, converting it into Callable will make it invalid, call it with `Call`
        /// from this class or pass to Godot as Variant through `Call` on the GodotObject class
        /// </returns>
        public static Variant Bindv(scoped in Godot.Callable callable, Godot.Collections.Array args) => CallableBindv.Execute([callable, args]);
        /// <inheritdoc cref="Bindv(in Godot.Callable, Godot.Collections.Array)" />
        public static Variant Bindv(scoped in Variant callable, Godot.Collections.Array args) => CallableBindv.Execute([callable, args]);

        /// <summary>
        /// Adds unbind to callable, casting returned callable is invalid, ConvertCallableToManaged doesn't take into 
        /// account native GDScript callables
        /// </summary>
        /// <returns>
        /// Copy with arguments unbound, converting it into Callable will make it invalid, call it with `Call`
        /// from this class or pass to Godot as Variant through `Call` on the GodotObject class
        /// </returns>
        public static Variant Unbind(scoped in Godot.Callable callable, int argCount) => CallableUnbind.Execute([callable, argCount]);
        /// <inheritdoc cref="Unbind(in Godot.Callable, int)" />
        public static Variant Unbind(scoped in Variant callable, int argCount) => CallableUnbind.Execute([callable, argCount]);

        public static Variant Call(scoped in Variant callable, scoped in Variant? arg = null)
        {
            if (arg is null)
                return CallableCallEmpty.Execute([callable]);
            else
                return CallableCall.Execute([callable, arg.Value]);
        }

        public static Variant Call(scoped in Godot.Callable callable, scoped in Variant? arg = null)
        {
            if (arg is null)
                return CallableCallEmpty.Execute([callable]);
            else
                return CallableCall.Execute([callable, arg.Value]);
        }
    }
}
