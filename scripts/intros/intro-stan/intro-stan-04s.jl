
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StanOptimize
	using StatisticalRethinking
end

md"## Intro-stan-04s.jl"

	stan1_1 = "
	// Inferring a rate
	data {
	  int N;
	  int<lower=1> n;
	  int<lower=0> k[N];
	}
	parameters {
	  real<lower=0,upper=1> theta;
	}
	model {
	  // Prior distribution for θ
	  theta ~ uniform(0, 1);

	  // Observed Counts
	  k ~ binomial(n, theta);
	}";

begin
	m1_1s = SampleModel("m1.1s", stan1_1)	# Define Stan language mdeol
	N = 25                              	# 25 experiments
	d = Binomial(9, 0.66)               	# 9 tosses (simulate 2/3 is water)
	k = rand(d, N)                      	# Simulate 15 trial results
	n = 9                               	# Each experiment has 9 tosses
	m1_1_data = Dict("N" => N, "n" => n, "k" => k)
	rc1_1s = stan_sample(m1_1s, data=m1_1_data)
	if success(rc1_1s)
		post1_1s_df = read_samples(m1_1s, output_format=:dataframe)
	end
end;

Text(precis(post1_1s_df; io = String))

begin
	sm_opt = OptimizeModel("m1.1s", stan1_1)
	rc_opt = stan_optimize(sm_opt; data=m1_1_data)
	optim_stan, cnames = read_optimize(sm_opt)
	optim_stan
end

md"##### This scripts shows a number of different ways to estimate a quadratic approximation."

md"##### Compare with Stan, MLE & MAP."

md"###### StanSample mean and sd (see also `intro_part_01`):"

part1_1s = Particles(post1_1s_df)

md"###### Stan_optimize mean and std (see also intro-part-03):"

begin
	mu_stan_optimize = mean(optim_stan["theta"])
	sigma_stan_optimize = std(post1_1s_df.theta, mean=mu_stan_optimize)
	[mu_stan_optimize, sigma_stan_optimize]
end

md"###### MLE estimate"

mle_fit = fit_mle(Normal, post1_1s_df.theta)

md"###### Use kernel density of Stan samples"

begin
	q1_1s = quap(m1_1s)
	quap1_1s_df = sample(q1_1s)
	mu_quap = mean(quap1_1s_df.theta)
	sigma_quap = std(quap1_1s_df.theta)
	[mu_quap, sigma_quap]
end

md"###### Using optim"

function loglik(x)
  ll = 0.0
  ll += log.(pdf.(Beta(1, 1), x[1]))
  ll += sum(log.(pdf.(Binomial(9, x[1]), k)))
  -ll
end

begin
	res = optimize(loglik, 0.0, 1.0)
	mu_optim = Optim.minimizer(res)[1]
	sigma_optim = std(post1_1s_df[:, :theta], mean=mu_optim)
	[mu_optim, sigma_optim]
end

md"###### Show the hpd region"

bnds_hpd = hpdi(post1_1s_df.theta, alpha=0.11)

begin
	x = 0.5:0.001:0.8
	plot( x, pdf.(Normal( mean(mle_fit) , std(mle_fit)) , x ),
		xlim=(0.5, 0.8), lab="MLE approximation",
		legend=:topleft, line=:dash)
	plot!( x, pdf.(Normal( mean(part1_1s.theta), std(part1_1s.theta)), x ),
		lab="Particle approximation", line=:dash)
	plot!( x, pdf.(Normal( mu_quap, sigma_quap), x ), lab="quap approximation")
	density!(post1_1s_df.theta, lab="StanSample chain")
	vline!([bnds_hpd[1]], line=:dash, lab="hpd lower bound")
	vline!([bnds_hpd[2]], line=:dash, lab="hpd upper bound")
end

md"In this example usually most approximations are similar. Other examples are less clear. In StatisticalRethinking.jl we have the actual Stan samples, quap() uses this to fit a Normal distribution with mean equal to the sample MAP."

md"## End of intro-stan/intro-stan-04s.jl"

