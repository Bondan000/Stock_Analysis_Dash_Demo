using StockDataAnalysis_Dash

app = create_app()
@info "Setup and now serving..."
port = something(tryparse(Int, get(ARGS, 1, "")), tryparse(Int, get(ENV, "PORT", "")), 8080)
run_server(app, "0.0.0.0", port)
