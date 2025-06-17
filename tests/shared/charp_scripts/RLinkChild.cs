using Godot;
using System;
using ValidRLink;

public partial class RLinkChild : Node
{
    [Export] public RLinkButtonCS ToggleDirectChild = new(nameof(ToggleDirectChildImpl));
    [Export] public RLinkButtonCS ToggleDirectChildPath = new(nameof(ToggleDirectChildPathImpl));
    [Export] public RLinkButtonCS ToggleChildPath = new(nameof(ToggleChildPathImpl));
    [Export] public RLinkButtonCS ToggleChildFrom = new(nameof(ToggleChildFromImpl));
    [Export] public RLinkButtonCS ToggleChildGetParent = new(nameof(ToggleChildGetParentImpl));
    [Export] public RLinkButtonCS ToggleHasFrom = new(nameof(ToggleHasFromImpl));
    [Export] public RLinkButtonCS RemoveAllChildren = new(nameof(RemoveAllChildrenImpl));
    [Export] public RLinkButtonCS RemoveAllChildrenFrom = new(nameof(RemoveAllChildrenFromImpl));
    [Export] public RLinkButtonCS RemoveAllChildrenPath = new(nameof(RemoveAllChildrenPathImpl));


    public void ToggleDirectChildImpl(RLinkCS rlink)
    {
        var child = rlink.GetNodeOrNull("DirectChild");
        if (child is not null)
        {
            rlink.RemoveChild(child);
        }
        else
        {
            child = new Node();
            child.Name = "DirectChild";
            rlink.AddChild(child);
        }
    }

    public void ToggleChildPathImpl(RLinkCS rlink)
    {
        if (rlink.HasNode("DirectChild/ChildPath"))
            rlink.RemoveChildPath("DirectChild/ChildPath");
        else
            rlink.AddChildPath("DirectChild/ChildPath", new Node());
    }

    public void ToggleDirectChildPathImpl(RLinkCS rlink)
    {
        if (rlink.HasNode("DirectChildPath"))
            rlink.RemoveChildPath("DirectChildPath");
        else
            rlink.AddChildPath("DirectChildPath", new Node());
    }

    public void ToggleChildFromImpl(RLinkCS rlink)
    {
        var directChild = rlink.GetNodeOrNull("DirectChild");
        if (directChild is null) return;

        var grandChild = rlink.GetNodeOrNullFrom(directChild, "ChildFrom");
        if (grandChild is not null)
        {
            rlink.RemoveChildFrom(directChild, grandChild);
        }
        else
        {
            grandChild = new Node();
            grandChild.Name = "ChildFrom";
            rlink.AddChildTo(directChild, grandChild);
        }
    }

    public void ToggleChildGetParentImpl(RLinkCS rlink)
    {
        var grandChild = rlink.GetNodeOrNull("DirectChild/GetParent");
        if (grandChild is not null)
        {
            rlink.RemoveChildFrom(rlink.GetParentFor(grandChild), grandChild);
        }
        else
        {
            rlink.AddChildPath("DirectChild/GetParent", new Node());
        }
    }

    public void ToggleHasFromImpl(RLinkCS rlink)
    {
        if (!rlink.HasNode("DirectChild")) return;
        var directChild = rlink.GetNodeOrNull("DirectChild");

        if (rlink.HasNodeFrom(directChild, "HasFrom"))
        {
            var grandChild = rlink.GetNodeOrNullFrom(directChild, "HasFrom");
            rlink.RemoveChildFrom(directChild, grandChild);
        }
        else
        {
            rlink.AddChildPath("DirectChild/HasFrom", new Node());
        }
    }

    public void RemoveAllChildrenImpl(RLinkCS rlink)
    {
        rlink.RemoveAllChildren();
    }

    public void RemoveAllChildrenFromImpl(RLinkCS rlink)
    {
        var directChild = rlink.GetNodeOrNull("DirectChild");
        if (directChild is null) return;
        rlink.RemoveAllChildrenFrom(directChild);
    }

    public void RemoveAllChildrenPathImpl(RLinkCS rlink)
    {
        rlink.RemoveAllChildrenPath("DirectChild");
    }
}
