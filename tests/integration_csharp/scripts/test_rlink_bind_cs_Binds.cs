
using System;
using Godot;

namespace ValidRLink;

[System.Diagnostics.CodeAnalysis.SuppressMessage("Style", "IDE1006:Naming Styles", Justification = "For ease of getting connected test by name")]
public partial class test_rlink_bind_cs_Binds : Node
{
    public static string Concat5(string a, string b, string c, string d, string e) => a + b + c + d + e;
    public static string Concat4(string a, string b, string c, string d) => a + b + c + d;
    public static string Concat3(string a, string b, string c) => a + b + c;
    public static string Concat2(string a, string b) => a + b;
    public static string Concat1(string a) => a;

    public static RLinkButtonCS Get5()
    {
        return new(Concat5);
    }
    public static RLinkButtonCS Get4()
    {
        return new(Concat4);
    }
    public static RLinkButtonCS Get3()
    {
        return new(Concat3);
    }
    public static RLinkButtonCS Get2()
    {
        return new(Concat2);
    }
    public static RLinkButtonCS Get1()
    {
        return new(Concat1);
    }
}