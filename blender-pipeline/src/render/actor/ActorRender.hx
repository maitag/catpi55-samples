package render.actor;

import haxe.ds.Vector;
import haxe.ds.IntMap;

import peote.view.PeoteView;

import render.RenderView;
import render.actor.simple.ElemSimple;

class ActorRender {

	//--------------- STATIC ---------------------------
	public static var peoteView:PeoteView;

	public static var stepTime:Float = 0.0;

	public static var config:Vector<ActorElemConfig>;
	public static var maxActions:Int;

	//--------------------------------------------------


	var elemViewBuffer:IntMap<ActorElem>;

	// -------------------------------------------------

 	public function new()
	{
	}

	public function initView(maxWidth:Int, maxHeight:Int) {
		elemViewBuffer = new IntMap<ActorElem>();
	}
	// TODO: reusing for new view
	// public function resetView() {}

	public inline function addActor(x:Int, y:Int, mapkey:Int, actorType:Int, offsetX:Int, offsetY:Int) {
		var px = x * RenderView.cellWidth + offsetX;
		var py = y * RenderView.cellHeight + offsetY;

		// TODO: add animation-ACTIONS !
		var conf = config.get(actorType * maxActions); // TODO: + actionType
		var element = switch(conf.renderType) {
			case SIMPLE: new ElemSimple(conf.tileStart, conf.sheetNr, px, py, conf.width, conf.height);
			case ANIM: null; // <-TODO
		} 
		elemViewBuffer.set(mapkey, element);
		element.add();
	}
	
	public inline function removeActor(mapkey:Int) {
		// trace("remove", mapkey);
		var element = elemViewBuffer.get(mapkey);
		// if (element!=null) {
			element.remove();
			elemViewBuffer.remove(mapkey);
		// }
	}

	// swaps the mapkeys if actor enters a new gridView
	public function actorChangeMapkey(oldMapkey:Int, newMapkey:Int) {
		// trace("actorChangeMapkey", oldMapkey, newMapkey);
		var element = elemViewBuffer.get(oldMapkey);
		elemViewBuffer.remove(oldMapkey);
		elemViewBuffer.set(newMapkey, element);
	}

	// ---- actor moves ----

	// TODO: animation

	public function actorGoLeft(mapkey:Int, time:Int) {
		var element = elemViewBuffer.get(mapkey);
		element.goLeft(peoteView.time, stepTime*time);
	}
	public function actorGoRight(mapkey:Int, time:Int) {
		var element = elemViewBuffer.get(mapkey);
		element.goRight(peoteView.time, stepTime*time);
	}
	public function actorGoUp(mapkey:Int, time:Int) {
		var element = elemViewBuffer.get(mapkey);
		element.goUp(peoteView.time, stepTime*time);
	}
	public function actorGoDown(mapkey:Int, time:Int) {
		var element = elemViewBuffer.get(mapkey);
		element.goDown(peoteView.time, stepTime*time);
	}

	public function actorGoLeftUp(mapkey:Int, time:Int) {
		var element = elemViewBuffer.get(mapkey);
		element.goLeftUp(peoteView.time, stepTime*time);
	}
	public function actorGoLeftDown(mapkey:Int, time:Int) {
		var element = elemViewBuffer.get(mapkey);
		element.goLeftDown(peoteView.time, stepTime*time);
	}
	public function actorGoRightUp(mapkey:Int, time:Int) {
		var element = elemViewBuffer.get(mapkey);
		element.goRightUp(peoteView.time, stepTime*time);
	}
	public function actorGoRightDown(mapkey:Int, time:Int) {
		var element = elemViewBuffer.get(mapkey);
		element.goRightDown(peoteView.time, stepTime*time);
	}



	// TODO
	public function updateActor(mapkey:Int, action:Int) { // TODO: action! 
		// TODO -> can also need to switch the renderType (so remove and add a new one of these type)!
	}



	// ------- for scrolling ----------
	
	public function allOffsetX(offset:Int) {
		for (element in elemViewBuffer) element.x += offset;
	}

	public function allOffsetY(offset:Int) {
		for (element in elemViewBuffer) element.y += offset;
	}


	
}