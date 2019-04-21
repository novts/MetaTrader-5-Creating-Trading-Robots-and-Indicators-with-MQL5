//+------------------------------------------------------------------+
//|                                                      TextOut.mq5 |
//|                                            Copyright 2018, NOVTS |
//|                                                 http://novts.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, NOVTS"
#property link      "http://novts.com"
#property version   "1.00"
#property indicator_chart_window

uint ExtImg[10000];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
ObjectCreate(0,"Image",OBJ_BITMAP_LABEL,0,0,0);
ObjectSetString(0,"Image",OBJPROP_BMPFILE,"::IMG");  
ArrayFill(ExtImg,0,10000,0xffffff);   
TextOut("Text",10,10,TA_LEFT|TA_TOP,ExtImg,100,100,0x000000,COLOR_FORMAT_XRGB_NOALPHA);
ResourceCreate("::IMG",ExtImg,100,100,0,0,0,COLOR_FORMAT_XRGB_NOALPHA);
ChartRedraw();
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
void  OnDeinit(const int reason){
ObjectsDeleteAll(0,-1,-1);
} 