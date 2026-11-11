package render;

import peote.view.PeoteView;
import peote.view.Texture;
import peote.view.TextureConfig;
import peote.view.TextureFormat;

import render.cell.CellRender;
import render.cell.CellConfigStatic;

import render.actor.ActorRender;

import asset.Util;
import asset.Sheet;

class Render {


	//--------------- STATIC ---------------------------

	public static var peoteView:PeoteView;

	public static var cellTexture:Texture;
	// public static var cellTextures:Array<Texture>;
	public static var actorTextures:Array<Texture>;





	public static function init(peoteView:PeoteView, stepTime:Int = 0)
	{
		Render.peoteView = peoteView;
		RenderView.peoteView = peoteView;

		// TODO: to make it more easy later to init them all together:
		
		// CellRender.init(peoteView);
		// ActorRender.init(peoteView, stepTime);
	}

	public static function initActor(peoteView:PeoteView, stepTime:Int, sheets:Array<Sheet>, config:ActorRenderConfig) {
		ActorRender.peoteView = peoteView;
		ActorRender.stepTime = stepTime / 860; // <- TODO

		var textureConfig:TextureConfig = {
			format:TextureFormat.RGBA,
			// smoothExpand: true,
			smoothShrink: true,
			// mipmap: true,
			powerOfTwo: false,
		};

		actorTextures = Util.loadTextures(sheets, textureConfig, false);

		var c = config.toConfigVector(sheets);
		RenderView.availActorTypes = c.renderTypeSheets;
		ActorRender.config = c.config;
		ActorRender.maxActions = c.maxActions;
	}

	public static function initCell(peoteView:PeoteView, sheets:Array<Sheet>, configStatic:CellConfigStatic) {
		CellRender.peoteView = peoteView;
		
		var textureConfig:TextureConfig = {
			format:TextureFormat.RGBA,
			// smoothExpand: true,
			smoothShrink: true,
			// mipmap: true,
			powerOfTwo: false,
		};

		cellTexture = Util.loadTextures(sheets, textureConfig, false)[0];
		// cellTextures = Util.loadTextures(sheets, textureConfig, false);

		CellRender.configStatic = configStatic.toConfigVector();
	}

}