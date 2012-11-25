package com.haxepunk;

import com.haxepunk.Entity;
import com.haxepunk.masks.CollisionInfo;
import com.haxepunk.masks.Masklist;
import flash.display.Graphics;
import flash.geom.Point;

typedef MaskCallback = Dynamic -> Bool;

/**
 * Base class for Entity collision masks.
 */
class Mask
{
	/**
	 * The parent Entity of this mask.
	 */
	public var parent:Entity;

	/**
	 * The parent Masklist of the mask.
	 */
	public var list:Masklist;

	/**
	 * Constructor.
	 */
	public function new()
	{
		_class = Type.getClassName(Type.getClass(this));
		_check = new Hash<MaskCallback>();
		_check.set(Type.getClassName(Mask), collideMask);
		_check.set(Type.getClassName(Masklist), collideMasklist);	}

	/**
	 * Checks for collision with another Mask.
	 * @param	mask	The other Mask to check against.
	 * @return	If the Masks overlap.
	 */
	public function collide(mask:Mask):Bool
	{
		if (parent == null)
		{
			throw "Mask must be attached to a parent Entity";
		}

		var cbFunc:MaskCallback = _check.get(mask._class);
		if (cbFunc != null) return cbFunc(mask);

		cbFunc = mask._check.get(_class);
		if (cbFunc != null) return cbFunc(this);

		return false;
	}

	/** @private Collide against an Entity. */
	private function collideMask(other:Mask):Bool
	{
		return parent.x - parent.originX + parent.width > other.parent.x - other.parent.originX
			&& parent.y - parent.originY + parent.height > other.parent.y - other.parent.originY
			&& parent.x - parent.originX < other.parent.x - other.parent.originX + other.parent.width
			&& parent.y - parent.originY < other.parent.y - other.parent.originY + other.parent.height;
	}

	private function collideMasklist(other:Masklist):Bool
	{
		return other.collide(this);
	}

	/** @private Assigns the mask to the parent. */
	public function assignTo(parent:Entity)
	{
		this.parent = parent;
		if (parent != null) update();
	}

	/**
	 * Override this
	 */
	public function debugDraw(graphics:Graphics, scaleX:Float, scaleY:Float):Void
	{

	}

	/** Updates the parent's bounds for this mask. */
	public function update()
	{

	}

	public inline function projectMask(axis:Point, collisionInfo:CollisionInfo):Void
	{
		var cur:Float,
			max:Float = -9999999999.,
			min:Float = 9999999999.;

		cur = -parent.originX * axis.x - parent.originY * axis.y;
		if (cur < min)
			min = cur;
		if (cur > max)
			max = cur;

		cur = (-parent.originX + parent.width) * axis.x - parent.originY * axis.y;
		if (cur < min)
			min = cur;
		if (cur > max)
			max = cur;

		cur = -parent.originX * axis.x + (-parent.originY + parent.height) * axis.y;
		if (cur < min)
			min = cur;
		if (cur > max)
			max = cur;

		cur = (-parent.originX + parent.width) * axis.x + (-parent.originY + parent.height)* axis.y;
		if (cur < min)
			min = cur;
		if (cur > max)
			max = cur;

		collisionInfo.min = min;
		collisionInfo.max = max;
	}

	// Mask information.
	private var _class:String;
	private var _check:Hash<MaskCallback>;
}