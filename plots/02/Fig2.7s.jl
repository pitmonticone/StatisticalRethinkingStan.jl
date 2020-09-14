# Fig2.7s.jl

using DrWatson
@quickactivate "StatisticalRethinkingStan"
using StanSample
using StatisticalRethinking

# ### snippet 2.5

p = Vector{Plots.Plot{Plots.GRBackend}}(undef, 3)
N = [5, 20, 50]

for i in 1:3            # Different priors
    local p_grid = range( 0 , stop=1 , length=N[i] )
    local prior = pdf.(Uniform(0, 1), p_grid)
    local likelihood = [pdf.(Binomial(9, p), 6) for p in p_grid]
    post = (prior .* likelihood) / sum(prior .* likelihood)
    p[i] = plot(p_grid, post, leg=false, title="$(N[i]) points")
    p[i] = scatter!(p_grid, post, leg=false)
end

plot(p..., layout=(1, 3))
savefig(plotsdir("02", "Fig2.7s.png"))

# End of Fig2.7s.jl
