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
		public var verbose:Boolean = false;

		public var initialObjectsProperties:Object;

		public function principal(autoinit:Boolean = true,autoEscala:Boolean = false, customFunctionsOnScale:Boolean = false,verbose:Boolean = false)
		{
			super();
			myStage = this.stage;
			origW = myStage.stageWidth;
			origH = myStage.stageHeight;
			myStage.scaleMode = StageScaleMode.NO_SCALE;
			myStage.align = StageAlign.TOP_LEFT;
			myStage.showDefaultContextMenu = false;
			this.verbose = verbose;
			if(autoEscala || escalar){
				ajusteAutomatico();
			}
		}
		
		public function ajusteAutomatico():void
		{
			if(initialObjectsProperties == null){
				initialObjectsProperties = new Object
			}
			posicionesOriginales();
			stage.addEventListener(Event.RESIZE,ajustarPantalla);
			stage.dispatchEvent(new Event(Event.RESIZE));
		}
		public function ajustarPantalla(e:Event,omitir:Array=null):void
		{
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
					if(!initialObjectsProperties.hasOwnProperty(mc.name)){
						var o:Object = {
							"x":mc.x,
							"y":mc.y,
							"scaleY":mc.scaleY,
							"scaleX":mc.scaleX,
							"target":mc,
							"name":mc.name,
							"visible":mc.visible,
							"alpha":mc.alpha
						}
						initialObjectsProperties[mc.name] = o;
					}
					if(escalar){
						mc.scaleX = mc.scaleY = ratioOrig[s]*ratio;
						if(mc.name == "main_stage" || mc.name == "loader_target"){
							mc.scaleX = mc.scaleY = ratioOrig[s]*ratioAlt;
						}
					}
					mc.x = origX[mc.name]*ratioX;
					mc.y = origY[mc.name]*ratioY;
				}
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
		
		public function update_pos(mc:DisplayObject,nx:Number,ny:Number,noScale :Boolean = false,newScale:Number = 0, noPos:Boolean = false,triggerEvent:Boolean = true){
			if(!noPos){
				origX[mc.name] = nx;
				origY[mc.name] = ny;
			}
			if((!noScale && ratioOrig.hasOwnProperty(mc.name)) || (noScale && !ratioOrig.hasOwnProperty(mc.name))){
				if(newScale>0){
					ratioOrig[mc.name] = newScale;
				}else{
					ratioOrig[mc.name] = mc.scaleX;
				}
			}
			if(triggerEvent){
				stage.dispatchEvent(new Event(Event.RESIZE));
			}
		}
		
		public function makebtn(mc:MovieClip,click:Function,over:Function = null,out:Function = null):void{
			mc.addEventListener(MouseEvent.CLICK,click);
			mc.buttonMode = true;
			mc.mouseChildren = false;
			mc.useHandCursor = true;
			if(over != null){
				mc.addEventListener(MouseEvent.ROLL_OVER,over);
			}
			if(out != null){
				mc.addEventListener(MouseEvent.ROLL_OUT,out);
			}
		}
		
		
		public function returnAsMovieClip():MovieClip
		{
			return MovieClip(this);
		}
		
		
		
		//algunos helpers
		
		override public function gotoAndPlay(frame:Object, scene:String=null):void{
			super.gotoAndPlay(frame,scene);
			dispatchEvent(new Event("eventgoToAndPlay",true));
		}
		
		override public function gotoAndStop(frame:Object, scene:String=null):void{
			super.gotoAndStop(frame,scene);
			dispatchEvent(new Event("eventgoToAndStop",true));
		}
		
		override public function stop():void{
			super.stop();
			dispatchEvent(new Event("eventStop",true)); //cambiese por el evento que sea necesario
		}
		
		
		
		//si el e.target tiene un fotograma llamado "s1" cuando uno hace over...
		public function over(e:MouseEvent):void{
			var mc:MovieClip = MovieClip(e.target);
			for(var i :int = 0; i< mc.currentLabels.length;i++){
				if(mc.currentLabels[i]["name"].indexOf("s1") > -1){
					mc.gotoAndPlay("s1");
				}
			}
		}

		//si el e.target tiene un fotograma llamado "s2" cuando uno hace out...
		public function out(e:MouseEvent):void{
			var mc:MovieClip = MovieClip(e.target);
			for(var i :int = 0; i< mc.currentLabels.length;i++){
				if(mc.currentLabels[i]["name"].indexOf("s2") > -1){
					mc.gotoAndPlay("s2");
				}
			}
		}
		
		
		public function jsTrace(...params):void{
			for(var i=0; i<params.length; i++){
				if(ExternalInterface.available){
					ExternalInterface.call("console.log",params[i]);
				}
				trace(params[i]);
			}
		}
		
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
		
		
		public function google_analytics(bt:String):void {
			trace("----------------------------LOG: "+bt);
			ExternalInterface.call("googleAnalytics",bt);
		}
		
		public static function isMail(email:String):Boolean{
			var emailExpression:RegExp = /^[a-z][\w.-]+@\w[\w.-]+\.[\w.-]*[a-z][a-z]$/i;
			return emailExpression.test(email);
		}
		
		
	}
}
