package render;

import peote.view.Program;
import peote.view.Texture;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;

import render.cell.CellRender;
import render.actor.ActorRender;
import render.cell.CellElemAnim;
import render.actor.ActorDisplay;
import render.cell.CellDisplay;
import render.cell.CellElemStatic;
import render.actor.simple.ProgSimple;

// TODO: replace by Int or renderCell
import catpi.automat.Cell;
import catpi.view.IRenderView;


class RenderView implements IRenderView{

	public static var peoteView:PeoteView;
	
	public static var availActorTypes:Map<ActorRenderType, Array<Int>>;
	// public static var availCellTypes:Map<CellRenderType, Array<Int>>;

// TODO: not all needs to be public!
	public var cellRender:CellRender;
	public var cellDisplay:CellDisplay;
	public var cellBufferStatic:Buffer<CellElemStatic>;
	public var cellBufferAnim:Buffer<CellElemAnim>;

	public var actorRender:ActorRender;
	public var actorDisplay:ActorDisplay;
	public var actorProgSimple:ProgSimple;
	// public var progAnim:ProgAnim;
	// public var prog1x1:Prog1x1Simple; // for 1x1 actor shapes and tilesheets

	// TODO: fbo-chain!
	// public var display:Display;

	
	// TODO: optimize to "cellSize" only (maybe static inline)
	public static var cellWidth:Int = 32;
	public static var cellHeight:Int = 32;

	//TODO:
	// public var zoom:Float;
	public var zoom(get,set):Float;
	inline function get_zoom():Float return cellDisplay.zoom;
	inline function set_zoom(z:Float):Float return cellDisplay.zoom = actorDisplay.zoom = z;
	
	//----------------------------------------------------

 	public function new(x:Int, y:Int, width:Int, height:Int)
	{
		// ---  CELL ----

		cellRender = new CellRender();

		cellBufferStatic = new Buffer<CellElemStatic>(1024, 512);
		cellBufferAnim = new Buffer<CellElemAnim>(1024, 512);//TODO

		cellDisplay = new CellDisplay(x, y, width, height,
			RenderView.cellWidth, RenderView.cellHeight,
			cellBufferStatic, cellBufferAnim, Render.cellTexture);
		
		peoteView.addDisplay(cellDisplay);


		// --- ACTOR ----

		actorRender = new ActorRender();
		// TODO: only for what is in usage by config
		var usedPrograms = new Array<Program>();
		for (renderType => sheets in availActorTypes)
		{
			var usedTextures = new Array<Texture>();
			for (sheet in sheets) usedTextures.push(Render.actorTextures[sheet]);
			usedPrograms.push(
				switch (renderType) {
					case SIMPLE: actorProgSimple = new ProgSimple(usedTextures, 1024, 512);
					case ANIM: null; // progAnim = ...
				}
			);
		}
		actorDisplay = new ActorDisplay(x, y, width, height, usedPrograms);
		peoteView.addDisplay(actorDisplay);

	}

	public function initView(maxWidth:Int, maxHeight:Int)
	{
		cellRender.initView(maxWidth, maxHeight);
		actorRender.initView(maxWidth, maxHeight);
	}


	// ------- delegating to Cell part ------
	public function addCells(xFrom:Int, yFrom:Int, xTo:Int, yTo:Int, cells:Array<Cell>) cellRender.addCells(xFrom, yFrom, xTo, yTo, cells, scrollOffsetX, scrollOffsetY);
	public function addCellsHorizontal(y:Int, xFrom:Int, xTo:Int, cells:Array<Cell>) cellRender.addCellsHorizontal(y, xFrom, xTo, cells, scrollOffsetX, scrollOffsetY);
	public function addCellsVertical(x:Int, yFrom:Int, yTo:Int, cells:Array<Cell>) cellRender.addCellsVertical(x, yFrom, yTo, cells, scrollOffsetX, scrollOffsetY);
	public function addCell(x:Int, y:Int, cellType:CellType) cellRender.addCell(x, y, cellType, scrollOffsetX, scrollOffsetY);
	public function removeCells(xFrom:Int, yFrom:Int, xTo:Int, yTo:Int) cellRender.removeCells(xFrom, yFrom, xTo, yTo);
	public function removeCellsHorizontal(y:Int, xFrom:Int, xTo:Int) cellRender.removeCellsHorizontal(y, xFrom, xTo);
	public function removeCellsVertical(x:Int, yFrom:Int, yTo:Int) cellRender.removeCellsVertical(x, yFrom, yTo);
	public function removeCell(x:Int, y:Int) cellRender.removeCell(x, y);

	// ------- delegating to Actor part ------
	public function addActor(x:Int, y:Int, mapkey:Int, actorType:Int) actorRender.addActor(x, y, mapkey, actorType, scrollOffsetX, scrollOffsetY);
	public function removeActor(mapkey:Int) actorRender.removeActor(mapkey);
	public function actorChangeMapkey(oldMapkey:Int, newMapkey:Int) actorRender.actorChangeMapkey(oldMapkey, newMapkey);
	public function actorGoLeft(mapkey:Int, time:Int) actorRender.actorGoLeft(mapkey, time);
	public function actorGoRight(mapkey:Int, time:Int) actorRender.actorGoRight(mapkey, time);
	public function actorGoUp(mapkey:Int, time:Int) actorRender.actorGoUp(mapkey, time);
	public function actorGoDown(mapkey:Int, time:Int) actorRender.actorGoDown(mapkey, time);
	public function actorGoLeftUp(mapkey:Int, time:Int) actorRender.actorGoLeftUp(mapkey, time);
	public function actorGoLeftDown(mapkey:Int, time:Int) actorRender.actorGoLeftDown(mapkey, time);
	public function actorGoRightUp(mapkey:Int, time:Int) actorRender.actorGoRightUp(mapkey, time);
	public function actorGoRightDown(mapkey:Int, time:Int) actorRender.actorGoRightDown(mapkey, time);
	



	// ------- scrolling ----------

	public var scrollOffsetX:Int = 0;
	public var scrollOffsetY:Int = 0;
	static inline var RESET_AT_OFFSET:Int = 16384;
	
	public function scrollLeft() {
		if (actorDisplay.xOffset >= RESET_AT_OFFSET) {			
			scrollOffsetX += RESET_AT_OFFSET;
			cellDisplay.xOffset -= RESET_AT_OFFSET;
			actorDisplay.xOffset -= RESET_AT_OFFSET;

			cellRender.allOffsetX(RESET_AT_OFFSET);
			actorRender.allOffsetX(RESET_AT_OFFSET);

			cellBufferStatic.update();
			// TODO-> actor buffer update for all here and after!			
		}
		cellDisplay.xOffset += RenderView.cellWidth;		
		actorDisplay.xOffset += RenderView.cellWidth;		
	}

	public function scrollRight() {
		if (actorDisplay.xOffset <= -RESET_AT_OFFSET) {			
			scrollOffsetX -= RESET_AT_OFFSET;
			actorDisplay.xOffset += RESET_AT_OFFSET;
			cellDisplay.xOffset += RESET_AT_OFFSET;

			cellRender.allOffsetX(-RESET_AT_OFFSET);
			actorRender.allOffsetX(-RESET_AT_OFFSET);

			cellBufferStatic.update();

		}
		cellDisplay.xOffset -= RenderView.cellWidth;
		actorDisplay.xOffset -= RenderView.cellWidth;
	}

	public function scrollTop() {
		if (actorDisplay.yOffset >= RESET_AT_OFFSET) {			
			scrollOffsetY += RESET_AT_OFFSET;
			cellDisplay.yOffset -= RESET_AT_OFFSET;
			actorDisplay.yOffset -= RESET_AT_OFFSET;

			cellRender.allOffsetY(RESET_AT_OFFSET);
			actorRender.allOffsetY(RESET_AT_OFFSET);

			cellBufferStatic.update();

		}
		cellDisplay.yOffset += RenderView.cellHeight;
		actorDisplay.yOffset += RenderView.cellHeight;
	}

	public function scrollBottom() {
		if (actorDisplay.yOffset <= -RESET_AT_OFFSET) {			
			scrollOffsetY -= RESET_AT_OFFSET;
			cellDisplay.yOffset += RESET_AT_OFFSET;
			actorDisplay.yOffset += RESET_AT_OFFSET;

			cellRender.allOffsetY(-RESET_AT_OFFSET);
			actorRender.allOffsetY(-RESET_AT_OFFSET);

			cellBufferStatic.update();

		}
		cellDisplay.yOffset -= RenderView.cellHeight;
		actorDisplay.yOffset -= RenderView.cellHeight;
	}
	
}