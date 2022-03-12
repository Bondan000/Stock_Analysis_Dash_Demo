module StockDataAnalysis_Dash

include("StockDataAnalysisBase.jl")

#using Dash, DashCoreComponents, DashHtmlComponents;
using Dash;

function hPlot(df, name::String = "Market Data")
    a = scatter(x = df.Date, y = df.Close, name = name)
    Plot(a)
end

export create_app, run_server

tui = HistData("TUI1.DE", today()-Year(2), today());
air = HistData("AIR.DE", today()-Year(2), today());
dal = HistData("DAL", today()-Year(2), today());
omv = HistData("OMV.DE", today()-Year(2), today());
rds = HistData("RDS-B", today()-Year(2), today());
sp500 = HistData("%5EGSPC", today()-Year(2), today());
dax = HistData("%5EGDAXI", today()-Year(2), today());
flu = HistData("FLU.VI", today()-Year(2), today());
ejt1 = HistData("EJT1.DE", today()-Year(2), today());
vow3 = HistData("VOW3.DE", today()-Year(2), today());
tl0 = HistData("TL0.DE", today()-Year(2), today());
sap = HistData("SAP.DE", today()-Year(2), today());
crude = HistData("CL%3DF", today()-Year(2), today());

CallSign_List = Dict(
    "TUI1" => tui,
    "AIR" => air, 
    "DAL" => dal, 
    "OMV" => omv, 
    "RDS.B" => rds,
    "S&P500" => sp500,
    "DAX" => dax,
    "FLU" => flu,
    "EJT1" => ejt1,
    "VOW3" => vow3,
    "TL0" => tl0,
    "SAP" => sap,
    "CRUDE" => crude);

function create_app()
#app = dash(external_stylesheets = ["https://codepen.io/chriddyp/pen/bWLwgP.css"])
app = dash(external_stylesheets = ["https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css"])
#app = dash()
app.title = "Stock Data Analysis - Demo"
app.layout = html_div(style = Dict("backgroundColor" => "#3D393B")) do 
#app.layout = html_div() do 
    html_h1("Stock Data Analysis - Demo", style = Dict("color" => "#dddddd", "textAlign" => "center"),),
    #html_div(),
   
    html_div(html_table(style=(width="75%",), vcat([
        html_tr([html_td(dcc_dropdown(id="call_id", options=
                [(label=s, value=s) for s in keys(CallSign_List)], placeholder="Select Call Sign", style=(width="50%",)))#=,
            html_td(dcc_checklist(id="compInp", options=[(label="Compare", value="OK")], style = Dict("color" => "#dce0e1"))),
            html_td(id="compInpList" , dcc_dropdown(id="inp2",options=
                [(label=s, value=s) for s in keys(CallSign_List)], multi=true, style=(width="100%",)))=#
            ])
        ]))
    ),

    #=html_div([
            html_div()
        ]
    ),=#

    html_div(html_p([
        dcc_graph(id="plot1")#, figure=Plot(tui,:Date,:Close))
    ])),
    #html_div(style = Dict("backgroundColor" => "#3D393B"), children=[html_div(id="div1"), html_div(id="div2")]),
    html_div(id="div1"),
    html_div(id="div2"),
    html_div(id="div3"),
    html_div(id="div4", html_footer(style = Dict("color" => "#dddddd", "textAlign" => "center"), [
            html_p(["Powered by ", html_a("Julia", href="https://julialang.org"), " + ", html_a("Plotly Dash", href="https://plotly.com/dash/"), " + ",
            html_a("DataFrames", href="https://github.com/JuliaData/DataFrames.jl"), " + ", html_a("CSVFiles", href="https://github.com/queryverse/CSVFiles.jl"),
            " + ", html_a("Query.jl", href="https://github.com/queryverse/Query.jl"), html_br(),
            "Data from ", html_a("Yahoo Finance", href="https://finance.yahoo.com/"), " Historic Data", html_br(), "© 2021 ",
            html_a("Bondan000", href="https://github.com/Bondan000")])]
            )
    )

end

#=callback!(app, Output("compInpList", "children"), Input("compInp", "value")) do x
    if x === nothing
        return nothing
    else
        return dcc_dropdown(id="inp2",options=[(label=s, value=s) for s in keys(CallSign_List)], multi=true, style=(width="90%",))
    end
end=#

callback!(app, Output("plot1", "figure"), Input("call_id", "value")) do x
    if x === nothing
        traces=GenericTrace[]
        for k in keys(CallSign_List)
            push!(traces, scatter(x=CallSign_List[k].Date, y=CallSign_List[k].Close, name=k))
        end
        return Plot(traces, Layout(yaxis=attr(type="log", gridcolor="#7f7f7f"), xaxis_gridcolor="#7f7f7f", 
        paper_bgcolor= "#615D5F", plot_bgcolor= "#615D5F", font_color="#000000", colorbar_tickcolor="#000000"))
    else
        return rcPlot(CallSign_List[x], x)
    end
end

callback!(app, Output("div1", "children"), Input("call_id", "value")) do x
    if x === nothing
        return nothing;
    else
        return dcc_graph(figure = mdPlot(CallSign_List[x], x))
    end
end

callback!(app, Output("div2", "children"), Input("call_id", "value")) do x
    if x === nothing
        return nothing;
    else
        return [html_span("Moving Average: ", style = Dict("color" => "#dce0e1")), dcc_input(id="m_avrg_inp1",type = "number", min=5, max=50, value=7, style=(margin="0 .2em 0 .2em",))]
    end
end

callback!(app, Output("div3", "children"), Input("call_id", "value"), Input("m_avrg_inp1", "value")) do x, meanAvrgInp
    if x === nothing
        return nothing;
    else
        return dcc_graph(figure = maPlot(CallSign_List[x], meanAvrgInp, x))
    end
end

return app
end

#@info "Setup and now serving..."
#port = something(tryparse(Int, get(ARGS, 1, "")), tryparse(Int, get(ENV, "PORT", "")), 8080)
#run_server(app, "0.0.0.0", port)
#run_server(app, "0.0.0.0", debug=false)

# use radio items to select the plots and a checkbox to compare 

end