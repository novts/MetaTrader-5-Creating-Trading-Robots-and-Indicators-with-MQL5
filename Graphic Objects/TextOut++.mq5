//+------------------------------------------------------------------+
//|                                                      TextOut.mq5 |
//|                                            Copyright 2018, NOVTS |
//|                                                 http://novts.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, NOVTS"
#property link      "http://novts.com"
#property version   "1.00"
#property indicator_chart_window

#resource "\\Images\\image.bmp"
uint ExtImg[10000];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
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
   //---
ArraySetAsSeries(time, true);
ArraySetAsSeries(high, true);
ArraySetAsSeries(low, true);
ArraySetAsSeries(close, true);
ObjectDelete(0,"Image");
ObjectCreate(0,"Image",OBJ_BITMAP,0,time[1],close[1]);
ObjectSetString(0,"Image",OBJPROP_BMPFILE,"::IMG");  
uint width=100;
uint height=100;
ResourceReadImage("::Images\\image.bmp",ExtImg,width,height);   
TextOut("Text",10,10,TA_LEFT|TA_TOP,ExtImg,100,100,0xffffff,COLOR_FORMAT_ARGB_NORMALIZE);
ResourceCreate("::IMG",ExtImg,100,100,0,0,0,COLOR_FORMAT_XRGB_NOALPHA);
ChartRedraw();

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
void  OnDeinit(const int reason){
ObjectsDeleteAll(0,-1,-1);
} 