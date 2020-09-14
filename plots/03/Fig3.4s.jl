# Fig3.2s.jl

using Pkg, DrWatson

@quickactivate "StatisticalRethinkingStan"
using StatisticalRethinking

p_grid = range(0, stop=1, length=10000)
prior = ones(length(p_grid))
likelihood = [pdf(Binomial(3, p), 3) for p in p_grid]
posterior = likelihood .* prior
posterior = posterior / sum(posterior)
samples = sample(p_grid, Weights(posterior), length(p_grid));

p1 = density(samples;
  xlab="Proportion water (p)", ylab="Density", lab="density",
  title="Mean, median & mode", leg=:topleft);
vline!(p1, [mode(samples)], lab="mode")
vline!(p1, [median(samples)], lab="median")
vline!(p1, [mean(samples)], lab="mean")

loss = map(p -> sum(posterior .* abs.(p .- p_grid)), p_grid)
m = findmin(loss)
p2 = plot(loss;
  xlab="Decision (p)", ylab="Expected proportional loss",
  title="Loss value", lab="Loss function");
scatter!([m[2]], [m[1]], lab="p_grid[$(m[2])]=$(round(m[1], digits=3))")
plot(p1, p2, layout=(1, 2))
savefig(plotsdir("03", "Fig3.4s.png"))
