using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang;
using Toybox.Graphics;
using Toybox.Time;
using Toybox.Time.Gregorian;

class GOTWatchFaceView extends Ui.WatchFace {

    	var customFont = null;
	var monImage = null;
	var hrIterator = null;
	var bgColor = 0x000000;
	var timeColor = 0x3366ff;
	var winterColor = 0x6699ff;
	var batteryColor = 0xffffff;

    // Load your resources here
    function onLayout(dc) {
    	
    	customFont = Ui.loadResource(Rez.Fonts.customFont);
        monImage = Ui.loadResource(Rez.Drawables.got); 
        hrIterator = ActivityMonitor.getHeartRateHistory(null, false);
    }
    
    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        
        var clockTime = Sys.getClockTime();   
        var sec  = clockTime.sec;      
        var timeString = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);
        var stats = Sys.getSystemStats();
        
        // Set Background Color        
        dc.setColor(bgColor, bgColor); 
        dc.clear();
        
        // Display Time
        dc.setColor(timeColor, bgColor);        
        dc.drawText(dc.getWidth()/2, 24 , customFont, timeString, Gfx.TEXT_JUSTIFY_CENTER);
        
        // Set Background image
        dc.drawBitmap(dc.getWidth()/2 - 50, 120, monImage);
        
        // Battery info
        dc.setColor(batteryColor, bgColor);
        dc.drawText(dc.getWidth()/2 + 85, 105 , Graphics.FONT_XTINY, stats.battery.format("%02d")+"%", Gfx.TEXT_JUSTIFY_CENTER);
            
        updateSecWidget(dc);
    	updateHeartRate(dc); 		    	
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }
    
    // Update a portion of the screen
    function onPartialUpdate(dc) {
    
    	updateSecWidget(dc);    	
    	updateHeartRate(dc);
    }
    
    // Handle a partial update exceeding the power budget
    function onPowerBudgetExceeded() {
    }
    
    function updateSecWidget(dc) {
    
    	var clockTime = Sys.getClockTime(); 
        var sec  = clockTime.sec;
        dc.setPenWidth(8);
        
        if(sec==0) {        
        	dc.setColor(bgColor, bgColor);        	
    		dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, dc.getWidth()/2 - 1, Gfx.ARC_COUNTER_CLOCKWISE, 90, 270 + 90);        
        } else {    	
    		dc.setColor(winterColor, bgColor);        	
    		dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, dc.getWidth()/2 - 1, Gfx.ARC_COUNTER_CLOCKWISE, 90, sec*6 + 90);
    	}
    }
    
    function updateHeartRate(dc) {
    
    	var heartRate=0;
	var heartColor = null;
	
	if (ActivityMonitor has :getHeartRateHistory) {
		var hrHist =  ActivityMonitor.getHeartRateHistory(1, true);
		heartRate = hrHist.next().heartRate;
	} else {
		heartRate = 0;
	}    	
    	
    	if(heartRate<110) { 
		// 0 to 110
		heartColor = 0xffffff;
	} else if(heartRate<150) {
		// 110 to 150
		heartColor = 0x00ff00;
	} else if(heartRate<170) {
		//150 to 170
		heartColor = 0xff8c00;
	} else {
		// over 170
		heartColor = 0xff0000;
	}	 
	   	
	dc.setColor(bgColor, bgColor);
	dc.fillRectangle(dc.getWidth()/2 - 105, 105, 40, 28);
	    
	dc.setColor(heartColor, bgColor);    	
	dc.drawText(dc.getWidth()/2 - 85, 105 , Graphics.FONT_XTINY, heartRate, Gfx.TEXT_JUSTIFY_CENTER);
    }

}
