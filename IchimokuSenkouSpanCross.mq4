//+------------------------------------------------------------------+
//|                                              IchimokuSpanCross  |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red

//---- buffers
double CrossUp[];
double CrossDown[];

//---- Ichimoku settings
input int Tenkan = 9;
input int Kijun = 26;
input int SenkouSpanB_Period = 52;
input double offset_point = 10.0;

int g_offset;
double g_senkouA, g_senkouB, g_prevA, g_prevB, g_senkouA_clone, g_senkouB_clone;
bool g_isEqual = false;

//+------------------------------------------------------------------+
int OnInit()
   {
    SetIndexBuffer(0, CrossUp);
    SetIndexStyle(0, DRAW_ARROW);
    SetIndexArrow(0, 233);
    SetIndexLabel(0, "SpanA Cross Above SpanB");

    SetIndexBuffer(1, CrossDown);
    SetIndexStyle(1, DRAW_ARROW);
    SetIndexArrow(1, 234);
    SetIndexLabel(1, "SpanA Cross Below SpanB");

    g_offset = offset_point * Point();
    g_senkouA_clone = 0;
    g_senkouB_clone = 0;

    return (INIT_SUCCEEDED);
   }
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
    for(int i = rates_total - (SenkouSpanB_Period + 1); i >= 0; i--)
       {
        int shift = i + Kijun;

        g_senkouA = iIchimoku(NULL, 0, Tenkan, Kijun, SenkouSpanB_Period, MODE_SENKOUSPANA, i);
        g_senkouB = iIchimoku(NULL, 0, Tenkan, Kijun, SenkouSpanB_Period, MODE_SENKOUSPANB, i);
        g_prevA = iIchimoku(NULL, 0, Tenkan, Kijun, SenkouSpanB_Period, MODE_SENKOUSPANA, i + 1);
        g_prevB = iIchimoku(NULL, 0, Tenkan, Kijun, SenkouSpanB_Period, MODE_SENKOUSPANB, i + 1);

        if(g_senkouA == g_senkouB)
           {
            if(g_isEqual == false)
               {
                g_senkouA_clone = g_prevA;
                g_senkouB_clone = g_prevB;
                g_isEqual = true;
               }
            continue;
           }
        else
            if(g_isEqual)
               {
                g_prevA = g_senkouA_clone;
                g_prevB = g_senkouB_clone;
                g_isEqual = false;
               }

        if(g_prevA < g_prevB && g_senkouA > g_senkouB)
            CrossUp[shift] = low[shift] - g_offset;
        else
            if(g_prevA > g_prevB && g_senkouA < g_senkouB)
                CrossDown[shift] = high[shift] + g_offset;
       }

    return (rates_total);
   }
//+------------------------------------------------------------------+
