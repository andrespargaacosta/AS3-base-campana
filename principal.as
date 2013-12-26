package com.luminarieWorks
{	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	import flash.xml.XMLNodeType;
		
	public class principal extends MovieClip
	{
		public var myStage:Stage;
		public var escalar:Boolean = true;
		public var origW:Number;
		public var origH:Number;
		public var actualW:Number;
		public var actualH:Number;
		public var origX:Object = {};
		public var origY:Object = {};
		public var ratioOrig:Object = {};
		public var num:Boolean = false;
		public var ratio:Number;
		public var ratioAlt:Number;
		public var ratioX:Number;
		public var ratioY:Number;

		public var externalConfig:Boolean = true;
				
		//array de funciones que se ejecutan cuando se escala...
		private var _customFunctionsOnScale:Boolean = false;
		public var _customFunctions:Array = new Array();
		public var _customFunctionsArgs:Array = new Array();
		public var dspList:Array = new Array();
		
		public function principal(autoinit:Boolean = true,autoEscala:Boolean = false, customFunctionsOnScale:Boolean = false)
		{
			super();
			myStage = this.stage;
			origW = myStage.stageWidth;
			origH = myStage.stageHeight;
			myStage.scaleMode = StageScaleMode.NO_SCALE;
			myStage.align = StageAlign.TOP_LEFT;
			myStage.showDefaultContextMenu = false;
			if(autoEscala || escalar){
				ajusteAutomatico();
			}
			if(customFunctionsOnScale){
				_customFunctionsOnScale = customFunctionsOnScale;
			}
		}
		
		public function ajusteAutomatico():void
		{
			posicionesOriginales();
			stage.addEventListener(Event.RESIZE,ajustarPantalla);
			stage.dispatchEvent(new Event(Event.RESIZE));
		}
		public function ajustarPantalla(e:Event,omitir:Array=null):void
		{
			//trace("AjustarPantalla Dispatched");
			actualH = myStage.stageHeight;
			actualW = myStage.stageWidth;

			ratioX = actualW/origW;
			ratioY = actualH/origH;
			ratio = getMin(ratioX,ratioY);
			ratioAlt = getMax(ratioX,ratioY);
			for(var i:int = 0;i<numChildren;i++){
				var mc:DisplayObject = DisplayObject(getChildAt(i));
				if(mc!=null){
					var s:String = mc.name;
					if(escalar){
						if(s.search("_w")>0){
							mc.scaleX = mc.scaleY = ratioOrig[s]*ratioX;
						}else{
							mc.scaleX = mc.scaleY = ratioOrig[s]*ratio;
						}
					}
					mc.x = origX[mc.name]*ratioX;
					mc.y = origY[mc.name]*ratioY;
				}
			}
			if(_customFunctionsOnScale){
				_customFunctions.forEach(execMe);
			}
		}
		
		public function addCustomResizeFunction(funcion:Function,params:Object = null):void{
			_customFunctions.push(funcion);
			_customFunctionsArgs.push(params);
		}
		
		private function execMe(element:*, index:int, array:Array):void
		{
			if(_customFunctionsArgs[index] != null){
				_customFunctions[index](_customFunctionsArgs[index]);
			}else{
				_customFunctions[index]();
			}
		}
		
		public function posicionesOriginales(omitir:Array=null){
			for(var i:int = 0;i<numChildren;i++){
				var mc:DisplayObject = DisplayObject(this.getChildAt(i));
				if(omitir != null){
					if(omitir.indexOf(mc)<0){
						origX[mc.name] = mc.x;
						origY[mc.name] = mc.y;
						ratioOrig[mc.name] = mc.scaleX;
					}
				}else{
					origX[mc.name] = mc.x;
					origY[mc.name] = mc.y;
					ratioOrig[mc.name] = mc.scaleX;
				}
				dspList.push(mc);
			}
		}
		
		public function getMin(a:Number,b:Number):Number{
			if(a<b){
				return a;
			}else{
				return b;
			}
		}
		
		public function getMax(a:Number,b:Number):Number{
			if(a>b){
				return a;
			}else{
				return b;
			}
		}
		
		public function update_pos(mc:DisplayObject,nx:Number,ny:Number,manualUpdate:Boolean = false){
			//if(origX[mc.name] == null){
				origX[mc.name] = nx;
				origY[mc.name] = ny;
			//}
			ratioOrig[mc.name] = mc.scaleX;
			if(!manualUpdate){
				stage.dispatchEvent(new Event(Event.RESIZE));
			}
			trace("posicion actualizada para "+mc.name+" - nx:"+nx+" ny:"+ny);
		}
		
		public function makebtn(mc:MovieClip,click:Function,over:Function = null,out:Function = null):void{
			//trace("1");
			mc.addEventListener(MouseEvent.CLICK,click);
			//trace("2");
			mc.buttonMode = true;
			//trace("3");
			mc.mouseChildren = false;
			//trace("4");
			mc.useHandCursor = true;
			//trace("5");
			if(over != null){
				//trace("5.1");
				mc.addEventListener(MouseEvent.ROLL_OVER,over);
			}
			if(out != null){
				//trace("5.2");
				mc.addEventListener(MouseEvent.ROLL_OUT,out);
			}
		}
		
		public function returnAsMovieClip():MovieClip
		{
			return MovieClip(this);
		}
		
		override public function gotoAndPlay(frame:Object, scene:String=null):void{
			super.gotoAndPlay(frame,scene);
			dispatchEvent(new InsaneEvent(InsaneEvent.CAMBIO_FRAME));
			//trace("gtp:"+me.currentFrameLabel);
		}
		
		override public function gotoAndStop(frame:Object, scene:String=null):void{
			super.gotoAndStop(frame,scene);
			dispatchEvent(new InsaneEvent(InsaneEvent.CAMBIO_FRAME));
			//trace("gts:"+me.currentFrameLabel);
		}
		
		override public function stop():void{
			super.stop();
			dispatchEvent(new InsaneEvent(InsaneEvent.STOP));
		}
		
		public function over(e:MouseEvent):void{
			e.target.gotoAndPlay("s1");
		}
		public function out(e:MouseEvent):void{
			e.target.gotoAndPlay("s2");
		}

		
		public function jsTrace(...params):void{
			for(var i=0; i<params.length; i++){
				ExternalInterface.call("console.log",params[i]);
				trace(params[i]);
			}
		}
		
		//algunos helpers
		
		public static function randRange(start:Number, end:Number) : Number  
		{  
			return Math.floor(start +(Math.random() * (end - start)));  
		}
		
		public static function trim( s:String ):String
		{
			return s.replace( /^([\s|\t|\n]+)?(.*)([\s|\t|\n]+)?$/gm, "$2" );
		}
		public static function htmlUnescape(str:String):String {
			return new XMLDocument(str).firstChild.nodeValue;
		}
		
		public static function htmlEscape(str:String):String {
			return XML( new XMLNode( XMLNodeType.TEXT_NODE, str ) ).toXMLString();
		}
		
	}
}
