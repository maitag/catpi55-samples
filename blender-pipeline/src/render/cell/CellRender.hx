package render.cell;

import haxe.ds.Vector;

import peote.view.PeoteView;

// TODO: replace by Int or renderCell
import catpi.automat.Cell;

import render.RenderView;

@:generic class ElemViewBuffer<T> {
	public var data:Vector<T>;
	public var sizeX:Int;
	public var sizeY:Int;	
	public inline function new(sizeX:Int, sizeY:Int) {	
		this.sizeX = sizeX;	
		this.sizeY = sizeY;
		data = new Vector( sizeX * sizeY );
	}
	// inline function modX(x:Int) return (x<0) ? sizeX+x : x % sizeX;
	// inline function modY(y:Int) return (y<0) ? sizeY+y : y % sizeY;
	inline function modX(x:Int) return (x<0) ? sizeX + ((x+1) % sizeX) - 1 : x % sizeX;
	inline function modY(y:Int) return (y<0) ? sizeY + ((y+1) % sizeY) - 1 : y % sizeY;

	inline function index(x:Int, y:Int) return modY(y) * sizeX + modX(x);
	public inline function get(x:Int, y:Int):T return data.get( index(x, y) );
	public inline function set(x:Int, y:Int, value:T) data.set( index(x, y), value );
}

class CellRender {

	//--------------- STATIC ---------------------------

	public static var peoteView:PeoteView;
	public static var configStatic:Vector<CellElemConfigStatic>;

	// -------------------------------------------------

	var elemViewBuffer:ElemViewBuffer<CellElemStatic>;

 	public function new() {		
	}

	public function initView(maxWidth:Int, maxHeight:Int) {
		elemViewBuffer = new ElemViewBuffer<CellElemStatic>(maxWidth, maxHeight);
	}
	// TODO: reset view for re-using
	// public function resetView() {}
	
	public function addCells(xFrom:Int, yFrom:Int, xTo:Int, yTo:Int, cells:Array<Cell>, offsetX:Int, offsetY:Int) {
		var i:Int = 0;
		for (y in yFrom...yTo)
			for (x in xFrom...xTo)
				addCell(x, y, cells[i++].type, offsetX, offsetY);
	}

	public function addCellsHorizontal(y:Int, xFrom:Int, xTo:Int, cells:Array<Cell>, offsetX:Int, offsetY:Int) {
		for (i in 0...(xTo - xFrom)) addCell(xFrom+i, y, cells[i].type, offsetX, offsetY);
	}

	public function addCellsVertical(x:Int, yFrom:Int, yTo:Int, cells:Array<Cell>, offsetX:Int, offsetY:Int) {
		for (i in 0...(yTo - yFrom)) addCell(x, yFrom+i, cells[i].type, offsetX, offsetY);
	}

	public inline function addCell(x:Int, y:Int, cellType:CellType, offsetX:Int, offsetY:Int) {
		var px = x * RenderView.cellWidth + offsetX;
		var py = y * RenderView.cellHeight + offsetY;

		// TODO: empty cells
		var config = configStatic.get(cellType);
		// var element = new CellElemStatic(config.tileNr, config.sheetNr, px, py);
		var element = new CellElemStatic(config.tileNr, px, py);
		elemViewBuffer.set(x, y, element);
		element.add();

	}

	public function removeCells(xFrom:Int, yFrom:Int, xTo:Int, yTo:Int) {
		for (y in yFrom...yTo)		
			for (x in xFrom...xTo)
				removeCell(x, y);
	}

	public function removeCellsHorizontal(y:Int, xFrom:Int, xTo:Int) {
		for (x in xFrom...xTo) removeCell(x, y);
	}

	public function removeCellsVertical(x:Int, yFrom:Int, yTo:Int) {
		for (y in yFrom...yTo) removeCell(x, y);
	}

	public inline function removeCell(x:Int, y:Int) {
		var element = elemViewBuffer.get(x, y);
		if (element!=null) {
			element.remove();
			elemViewBuffer.set(x, y, null);
		}
	}


	public function updateCell(x:Int, y:Int) {
		// TODO
	}


	// ------- for scrolling ----------
	
	public function allOffsetX(offset:Int) {
		for (i in 0...elemViewBuffer.data.length) {
			var element = elemViewBuffer.data.get(i);
			if (element!=null) element.x += offset;
		}
	}

	public function allOffsetY(offset:Int) {
		for (i in 0...elemViewBuffer.data.length) {
			var element = elemViewBuffer.data.get(i);
			if (element!=null) element.y += offset;
		}
	}



}