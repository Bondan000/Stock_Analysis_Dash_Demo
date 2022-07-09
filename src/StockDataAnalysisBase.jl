#Author: Binto N

module StockDataAnalysisBase

using CSVFiles, Query, DataFrames, Statistics, Dates, Plotly


function yDate(dt)
    refDateNo = 1577836800
    refDate = Date("2020-01-01")
    Date(dt) == refDate ? refDateNo : (Date(dt) > refDate ? (refDateNo+Dates.value((Date(dt)-refDate)*86400)) : (refDateNo-Dates.value((refDate-Date(dt))*86400)))
end

"""
    HistData(callSign::String, period1, period2)\n
This function fetches historical market data from https://finance.yahoo.com and return data as a DataFrame without `missing` or `NA` values. Input values are 'callSign', 'period1' and 'period2'.\n
`callSign`: provide the call sign for the company of interest. Eg.: "TUI1.DE", "AAPL".\n
`period1`: give the start date ("yyyy-mm-dd") for the historical data.\n
`period2`: give the end date ("yyyy-mm-dd") for the historical data.
"""
function HistData(callSign::String, period1, period2)
    if Date(period2)<=Date(period1)
        return("Period 1 is smaller than period 2! Please enter correct time frame!")
    else
        sleep(rand(2:10))
        dta = load(File(format"CSV", "https://query1.finance.yahoo.com/v7/finance/download/$callSign?period1=$(yDate(period1))&period2=$(yDate(period2))&interval=1d&events=history&includeAdjustedClose=true")) |> DataFrame
        dta[!, :Voltality] = dta[:, :High] - dta[:, :Low]
        dropmissing!(dta)
        return(dta)
    end
end

"""
    mdPlot(df::DataFrame, name::String="Market Data")\n
`mdPlot` is short for 'market data plot' This function plots the market data with the relevant values like 'OHLC', 'Volume' and 'Voltality'. 
The function takes input `df` as DataFrame and optionally one can name the legend.
"""
function mdPlot(df::DataFrame, name::String="Market Data")
    a = bar(x=df.Date, y=df.Volume, name="Volume", yaxis="y3")
    b = ohlc(x = df.Date, open = df.Open, high = df.High, low = df.Low, close=df.Close, name = name, yaxis="y2")
    c = scatter(x=df.Date, y=df.Voltality, name=("Voltality, Mean Value = $(Float16(mean(df.Voltality)))"))
    data = [a, b, c]
    layout = Layout(yaxis = attr(title = "Price", domain=[0, 0.3], gridcolor="#7f7f7f"),
                yaxis2 = attr(title = "Price", domain=[0.3, 0.7], gridcolor="#7f7f7f"),
                yaxis3 = attr(title = "Volume", domain=[0.7, 1], gridcolor="#7f7f7f"),
                xaxis_gridcolor="#7f7f7f", paper_bgcolor= "#615D5F", plot_bgcolor= "#615D5F", 
                font_color="#000000", colorbar_tickcolor="#000000")
    Plot(data, layout)
end

"""
    vPlot(df::DataFrame, name::String="")
`vPlot` stands for 'volume plot'.
"""
function vPlot(df::DataFrame, name::String="")
    a = bar(x= df.Date, y=df.Volume, name = "$name Volume")
    b = scatter(x=df.Date, y = collect(Iterators.repeated(mean(df.Volume), length(df.Date))), name = "Mean Value")
    layout = Layout(yaxis=attr(title="Volume"))
    #layout = Layout(yaxis=attr(title="Volume"), shapes = hline([mean(df.Volume)], line_color = "orange", name = "Mean Value"))
    #layout = Layout(xaxis=attr(rangeslider=attr(visible ="true")), type = "date")
    Plot([a,b], layout)
    #plot([a,b])
end

"""
    localmins(dta)
first of the two methods that return local minimum of an given array!
"""
function localmins(dta)
    lmins = []
    for i in 1:length(dta)-2
        if (dta[i]-dta[i+1]) > 0 && (dta[i+1]-dta[i+2]) < 0
            append!(lmins, dta[i+1])
        end
    end
    return lmins
end

"""
    localmaxs(dta)
first of the two methods that return local maximum of an given array!
"""
function localmaxs(dta)
    lmaxs = []
    for i in 1:length(dta)-2
        if (dta[i]-dta[i+1]) < 0 && (dta[i+1]-dta[i+2]) > 0
            append!(lmaxs, dta[i+1])
        end
    end
    return lmaxs
end

"""
    localmins(df::DataFrame)
the second one takes the input as a DataFrame!
"""
function localmins(df::DataFrame)
    lmins = DataFrame()
    for i in 1:length(df.Close)-2
        if (df.Close[i]-df.Close[i+1]) > 0 && (df.Close[i+1]-df.Close[i+2]) < 0
            append!(lmins, [(Date = df.Date[i+1], Minimum = df.Close[i+1])])
        end
    end
    return lmins
end

"""
    localmaxs(df::DataFrame)
the second one takes the input as a DataFrame!
"""
function localmaxs(df::DataFrame)
    lmaxs = DataFrame()
    for i in 1:length(df.Close)-2
        if (df.Close[i]-df.Close[i+1]) < 0 && (df.Close[i+1]-df.Close[i+2]) > 0
            append!(lmaxs, [(Date = df.Date[i+1], Maximum = df.Close[i+1])])
        end
    end
    return lmaxs
end

"""
    localextremas(df::DataFrame)
`localextremas`, as the name says gives the local extremas back. 
"""
function localextremas(df::DataFrame)
    lextremas = DataFrame()
    for i in 1:length(df.Close)-2
        if (df.Close[i]-df.Close[i+1]) > 0 && (df.Close[i+1]-df.Close[i+2]) < 0
            append!(lextremas, [(Date = df.Date[i+1], Extrema = df.Close[i+1])])
        elseif (df.Close[i]-df.Close[i+1]) < 0 && (df.Close[i+1]-df.Close[i+2]) > 0
            append!(lextremas, [(Date = df.Date[i+1], Extrema = df.Close[i+1])])
        end
    end
    return lextremas
end
function relChange(df::DataFrame)
    lextrema = localextremas(df)
    relChg = DataFrame()
    for i in 1:length(lextrema.Extrema)-1
        for j in 1:length(df.Close)-1
            if df.Date[j] == lextrema.Date[i]
                k=j+1
                while df.Date[k] <= lextrema.Date[i+1]
                    append!(relChg, [(Date = df.Date[k], RelChange = (100 * (df.Close[k]/lextrema.Extrema[i]))-100)])
                    k +=1
                end
            end
        end
    end
    return relChg
end

"""
    ePlot(df::DataFrame, name::String="Market Data")
`ePlot` is for plotting the local extremas. It also supports drawing custom lines in the plot!
"""
function ePlot(df::DataFrame, name::String="Market Data")
    lmins = localmins(df)
    lmaxs = localmaxs(df)
    a = scatter(x = df.Date, y = df.Close, name=name)
    b = scatter(x = lmins.Date, y = lmins.Minimum, name="Minimum", mode=:markers)#, marker_color=:red)
    c = scatter(x = lmaxs.Date, y = lmaxs.Maximum, name="Maximum", mode=:markers)#, marker_color=:green)
    layout = Layout(yaxis = attr(title = "Price"))
    #config = Dict(:modeBarButtonsToAdd => ["drawline","eraseshape"])
    #plot([a,b,c], layout; options=config)
    Plot([a,b,c], layout)
end

"""
    rcPlot(df::DataFrame, name::String="Market Data")
`rcPlot` for 'relative change plot'.
"""
function rcPlot(df::DataFrame, name::String="Market Data")
    lmins = localmins(df)
    lmaxs = localmaxs(df)
    relchg = relChange(df)
    a = scatter(x = df.Date, y = df.Close, name=name)
    b = scatter(x = lmins.Date, y = lmins.Minimum, name="Minimum", mode=:markers)#, marker_color=:red)
    c = scatter(x = lmaxs.Date, y = lmaxs.Maximum, name="Maximum", mode=:markers)#, marker_color=:green)
    d = scatter(x = relchg[:,1], y= relchg[:,2], name = "% rel. Change", yaxis="y2")
    layout = Layout(yaxis = attr(title = "Price", gridcolor="#7f7f7f"),
        yaxis2=attr(title="rel. change [%]", anchor="x", overlaying = "y", side="right", position=1, gridcolor="#7f7f7f"),
        xaxis_gridcolor="#7f7f7f", paper_bgcolor= "#615D5F", plot_bgcolor= "#615D5F", 
        font_color="#000000", colorbar_tickcolor="#000000")
    Plot([a,b,c,d], layout)
end

"""
    ChartAnalyse(df::DataFrame, name::String="Market Data")
`ChartAnalyse` plots `mdPlot`, `vPlot` and `rcPlot`.
"""
function ChartAnalyse(df::DataFrame, name::String="Market Data")
    mdPlot(df, name) |> display
    vPlot(df, name) |> display
    rcPlot(df, name) |> display
end

"""
    MovAvg(dta::Array, period::Int = 10)
`MovAvg` calculates moving average of a given array.\n
`period`: default value is 10. `period` must be smaller than the length of the input array.
"""
function MovAvg(dta::Array, period::Int = 10)
    mean_values = Array{Float64}(undef,0)
    if period > length(dta)
        return("Period larger than the array length! Please enter a smaller value!")
    else
        for i in 1:length(dta)-period+1
            push!(mean_values, mean(dta[i:i+period-1]))
        end
    end
    return mean_values
end

"""
    maPlot(df::DataFrame, period::Int = 10, name::String = "Market Data")
To plot the moving average. `period` can to be set, default value is 10.
"""
function maPlot(df::DataFrame, period::Int = 10, name::String = "Market Data")
    a = scatter(x = df.Date, y = df.Close, name = name)
    b = scatter(x = df.Date[period:end], y = MovAvg(df.Close, period), name = "$period Days Moving Average")
    layout = Layout(xaxis_gridcolor="#7f7f7f",yaxis = attr(title = "Price",gridcolor="#7f7f7f"), paper_bgcolor= "#615D5F", plot_bgcolor= "#615D5F", font_color="#000000",colorbar_tickcolor="#000000")
    Plot([a,b], layout)
end

export HistData, mdPlot, vPlot, localextremas, ePlot, rcPlot, ChartAnalyse

end