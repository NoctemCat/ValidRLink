using Godot;
using Godot.Collections;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Threading;
using System.Threading.Tasks;
using ValidRLink;

[Tool]
public partial class BasicValidateCSharp : Node
{
    [Signal] public delegate void TestEventHandler();
    int ab = 20;
    // [Export]
    // public Callable SetButton;
    [Export]
    public RLinkButtonCS ButtsssonCS2
        = new RLinkButtonCS(nameof(TestInt))
        .SetText("Hello").SetIcon("Clear").SetMarginBottom(40);
    [Export]
    public Callable TestInfoCall234
    {
        get => new(this, MethodName.TestInfoOther);
        private set { }
    }
    [Export]
    public Callable TestInfoCallDirect;

    [Export] public int IntVar { get; set; }

    [Export]
    public RLinkButtonCS Lambda;
    // public Delegate test;
    public BasicValidateCSharp()
    {
        TestInfoCallDirect = new(this, MethodName.TestInfoOther);
        Lambda = new(nameof(TestStatic));
        // TestInfoCall = new(this, MethodName.TestInfoOther)
        //     // SetButton = Callable.From(TestInfo);
        //     buttonCS = new(TestInfo); //
        //toolButton = Callable.From(TestInfo);

        // test = TestInt;

    }

    public static void TestStatic()
    {
        GD.Print("Hello static");
    }
    public bool TestInfo(RLinkCS rlink)
    {
        // GD.PrintS("yeee", HasMethod(MethodName.TestInt));
        // FunctionState
        // Func<RLinkCS, Task<bool>> func = TestInt;
        // test.DynamicInvoke([rlink]);
        // var tt = TestInt;
        // tt.Invoke(rlink);
        IntVar++; //
        GD.PrintS("!!!!!!!!!");
        return false;
    }
    public void TestInfoOther(RLinkCS rlink) //
    {
        GD.PrintS("aaauuuuuuuuuuu");
    }

    public async Task TestInt(RLinkCS rlink, CancellationToken token) //
    {
        // IAsyncEnumerable
        // bool bar = true;
        // object dict = new Godot.Collections.Dictionary<int, int>() { { 1, 2 } }; //
        // GodotHelper.TryToVariant(dict, out Variant variant);
        // await ;
        IntVar++;
        // GD.PrintS("leaked before", rlink, variant.VariantType.ToString()); //
        // await ToSignal(rlink.GetTree().CreateTimer(2), "timeout")._WaitAsync(token);
        //await ToTask(rlink).WaitAsync(token);
        await Task.Delay(400);
        GD.Print("after");
        IntVar++;

        // Callable callable = new(this, MethodName.SomeVariant);
        // // Variant varCallable = callable;
        // // callable = varCallable.AsCallable();
        // Variant callableVar = GodotHelper.CallableHelper.Bind(callable, 22);
        // // callableVar = GodotHelper.CallableInfo.Unbind(callableVar, 1);

        // GD.PrintS("From callable:", GodotHelper.CallableHelper.Call(callableVar));

        // Variant variant1 = rlink.GetNodeOrNull("Button").Call("get_callable");
        // Callable callable = (Callable)variant1;
        // GD.PrintS(variant1, callable, callable.Call());
        // Call();
        //return true;

        Expression CallableBind = new();
        CallableBind.Parse("callable.bind(argument)", ["callable", "argument"]);
        Expression CallableCallEmpty = new();
        CallableCallEmpty.Parse("callable.call()", ["callable"]);

        Callable callable = new(this, MethodName.Plus110);
        Variant callableBound = CallableBind.Execute([callable, 10]);

        int result = CallableCallEmpty.Execute([callableBound]).AsInt32();
        GD.Print($"Result is {result}");

        Callable casted = callableBound.AsCallable();
        GD.Print($"{callableBound} | {casted}");

        Call(
            GodotObject.MethodName.Connect,
            [SignalName.Test, CallableBind.Execute([new Callable(this, MethodName.PrintInt), 456]), (long)ConnectFlags.OneShot]
        );
        EmitSignalTest();
        // Connect(MethodName.Plus110, callable, GodotObject.ConnectFlags.OneShot);

        // Call()
    }
    public int Plus110(int a)
    {
        return a + 110;
    }

    public void PrintInt(int a) => GD.Print($"Int: {a}");

    public async Task ToTask(RLinkCS rlink)
    {
        SceneTreeTimer timer = rlink.GetTree().CreateTimer(6); //
        SignalAwaiter awaiter = ToSignal(timer, "timeout");

        GD.PrintS("leaked>>>", timer, awaiter);
        await awaiter;
    }
    // ValidatePO


}
