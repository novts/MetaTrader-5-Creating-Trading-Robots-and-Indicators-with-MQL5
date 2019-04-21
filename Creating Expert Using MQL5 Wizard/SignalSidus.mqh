//+------------------------------------------------------------------+
//|                                                  SignalSidus.mqh |
//|                                            Copyright 2018, NOVTS |
//|                                                 http://novts.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, NOVTS"
#property link      "http://novts.com"

#include <Expert\ExpertSignal.mqh>

// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=Signals of the system 'Sidus'                              |
//| Type=SignalAdvanced                                              |
//| Name=Sidus                                                       |
//| ShortName=MA                                                     |
//| Class=CSignalSidus                                               |
//| Page=                                                            |
//| Parameter=NumberOpenPosition,int,5,Bars number checked to cross  |
//| Parameter=Pattern_0,int,80,Model 0                               |
//| Parameter=Pattern_1,int,20,Model 1                               |
//| Parameter=Pattern_2,int,80,Model 2                               |
//+------------------------------------------------------------------+
// wizard description end
//+------------------------------------------------------------------+
//| Class CSignalSidus.                                              |
//| Purpose: Class of generator of trade signals based on            |
//|          the 'Sidus' system.                                     |
//| Is derived from the CExpertSignal class.                         |
//+------------------------------------------------------------------+

class CSignalSidus : public CExpertSignal
  {
protected:
   CiMA              m_ma18;             // object-indicator
   CiMA              m_ma28;             // object-indicator
   CiMA              m_ma5;             // object-indicator
   CiMA              m_ma8;             // object-indicator
   //--- adjusted parameters
   int m_numberOpenPosition;
   //--- "weights" of market models (0-100)
   int               m_pattern_0;      // model 0 "5 WMA and 8 WMA cross the 18 EMA and the 28 EMA upward or top down" 80
   int               m_pattern_1;      // model 1 "5 WMA crosses the 8 WMA upward or top down" 10
   int               m_pattern_2;      // model 2 "18 EMA crosses the 28 EMA upward or top down" 80

public:
                     CSignalSidus(void);
                    ~CSignalSidus(void);
   //--- methods of setting adjustable parameters
   void              NumberOpenPosition(int value)                 { m_numberOpenPosition=value;    }                
   //--- methods of adjusting "weights" of market models
   void              Pattern_0(int value)                { m_pattern_0=value;          }
   void              Pattern_1(int value)                { m_pattern_1=value;          }
   void              Pattern_2(int value)                { m_pattern_2=value;          }
   //--- method of verification of settings
   virtual bool      ValidationSettings(void);
   //--- method of creating the indicator and timeseries
   virtual bool      InitIndicators(CIndicators *indicators);
   //--- methods of checking if the market models are formed
   virtual int       LongCondition(void);
   virtual int       ShortCondition(void);
protected:
   //--- method of initialization of the indicator
   bool              InitMA(CIndicators *indicators);   
  };

CSignalSidus::CSignalSidus(void) : m_numberOpenPosition(5),
                                   m_pattern_0(80),
                                   m_pattern_1(10),
                                   m_pattern_2(80)
  {
//--- initialization of protected data
   m_used_series=USE_SERIES_OPEN+USE_SERIES_HIGH+USE_SERIES_LOW+USE_SERIES_CLOSE;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSignalSidus::~CSignalSidus(void)
  {
  }  
//+------------------------------------------------------------------+
//| Validation settings protected data.                              |
//+------------------------------------------------------------------+
bool CSignalSidus::ValidationSettings(void)
  {
//--- validation settings of additional filters
   if(!CExpertSignal::ValidationSettings())
      return(false);

//--- ok
   return(true);
  }  
//+------------------------------------------------------------------+
//| Create indicators.                                               |
//+------------------------------------------------------------------+
bool CSignalSidus::InitIndicators(CIndicators *indicators)
  {
//--- check pointer
   if(indicators==NULL)
      return(false);
//--- initialization of indicators and timeseries of additional filters
   if(!CExpertSignal::InitIndicators(indicators))
      return(false);
//--- create and initialize MA indicator
   if(!InitMA(indicators))
      return(false);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialize MA indicators.                                        |
//+------------------------------------------------------------------+
bool CSignalSidus::InitMA(CIndicators *indicators)
  {
//--- check pointer
   if(indicators==NULL)
      return(false);
//--- add object to collection
   if(!indicators.Add(GetPointer(m_ma18)))
     {
      printf(__FUNCTION__+": error adding object");
      return(false);
     }
//--- initialize object
   if(!m_ma18.Create(m_symbol.Name(),m_period,18,0,MODE_EMA,PRICE_WEIGHTED))
     {
      printf(__FUNCTION__+": error initializing object");
      return(false);
     }
     //--- add object to collection
   if(!indicators.Add(GetPointer(m_ma28)))
     {
      printf(__FUNCTION__+": error adding object");
      return(false);
     }
//--- initialize object
   if(!m_ma28.Create(m_symbol.Name(),m_period,28,0,MODE_EMA,PRICE_WEIGHTED))
     {
      printf(__FUNCTION__+": error initializing object");
      return(false);
     }
//--- add object to collection
   if(!indicators.Add(GetPointer(m_ma5)))
     {
      printf(__FUNCTION__+": error adding object");
      return(false);
     }
//--- initialize object
   if(!m_ma5.Create(m_symbol.Name(),m_period,5,0,MODE_LWMA,PRICE_WEIGHTED))
     {
      printf(__FUNCTION__+": error initializing object");
      return(false);
     } 
 //--- add object to collection
   if(!indicators.Add(GetPointer(m_ma8)))
     {
      printf(__FUNCTION__+": error adding object");
      return(false);
     }
//--- initialize object
   if(!m_ma8.Create(m_symbol.Name(),m_period,8,0,MODE_LWMA,PRICE_WEIGHTED))
     {
      printf(__FUNCTION__+": error initializing object");
      return(false);
     }            
//--- ok
   return(true);
  }    
//+------------------------------------------------------------------+
//| "Voting" that price will grow.                                   |
//+------------------------------------------------------------------+
int CSignalSidus::LongCondition(void)
  {
   int result=0;
   int idx=StartIndex();   
if(m_ma5.Main(idx)>m_ma8.Main(idx)&&m_ma8.Main(idx)>m_ma18.Main(idx)&&m_ma8.Main(idx)>m_ma28.Main(idx)){
bool flagCross1=false;
bool flagCross2=false;
for (int i=(idx+1);i<m_numberOpenPosition;i++){
if(m_ma5.Main(i)<m_ma18.Main(i)&&m_ma5.Main(i)<m_ma28.Main(i)){
 flagCross1=true;
 }
 if(m_ma8.Main(i)<m_ma18.Main(i)&&m_ma8.Main(i)<m_ma28.Main(i)){
 flagCross2=true;
 }} 
 if(flagCross1==true&&flagCross2==true){
 result=m_pattern_0;
 }} 
if(m_ma5.Main(idx)>m_ma8.Main(idx)){
bool flagCross=false;
for (int i=(idx+1);i<m_numberOpenPosition;i++){
if(m_ma5.Main(i)<m_ma8.Main(i)){
 flagCross=true;
 }} 
 if(flagCross==true){
 result=m_pattern_1;
 }} 
 if(m_ma18.Main(idx)>m_ma28.Main(idx)){
bool flagCross=false;
for (int i=(idx+1);i<m_numberOpenPosition;i++){
if(m_ma18.Main(i)<m_ma28.Main(i)){
 flagCross=true;
 }} 
 if(flagCross==true){
 result=m_pattern_2;
 }}  
   return result;
 } 
//+------------------------------------------------------------------+
//| "Voting" that price will fall.                                   |
//+------------------------------------------------------------------+
int CSignalSidus::ShortCondition(void)
  {
   int result=0;
   int idx   =StartIndex();   
if(m_ma5.Main(idx)<m_ma8.Main(idx)&&m_ma8.Main(idx)<m_ma18.Main(idx)&&m_ma8.Main(idx)<m_ma28.Main(idx)){
bool flagCross1=false;
bool flagCross2=false;
for (int i=(idx+1);i<m_numberOpenPosition;i++){
if(m_ma5.Main(i)>m_ma18.Main(i)&&m_ma5.Main(i)>m_ma28.Main(i)){
 flagCross1=true;
 }
 if(m_ma8.Main(i)>m_ma18.Main(i)&&m_ma8.Main(i)>m_ma28.Main(i)){
 flagCross2=true;
 }} 
 if(flagCross1==true&&flagCross2==true){
 result=m_pattern_0;
 }} 
if(m_ma5.Main(idx)<m_ma8.Main(idx)){
bool flagCross=false;
for (int i=(idx+1);i<m_numberOpenPosition;i++){
if(m_ma5.Main(i)>m_ma8.Main(i)){
 flagCross=true;
 }} 
 if(flagCross==true){
 result=m_pattern_1;
 }} 
if(m_ma18.Main(idx)<m_ma28.Main(idx)){
bool flagCross=false;
for (int i=(idx+1);i<m_numberOpenPosition;i++){
if(m_ma18.Main(i)>m_ma28.Main(i)){
 flagCross=true;
 }} 
 if(flagCross==true){
 result=m_pattern_2;
 }}   
   return result;
 }  
