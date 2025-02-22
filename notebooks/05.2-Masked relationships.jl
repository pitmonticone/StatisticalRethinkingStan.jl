### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ 16ddb41a-fc59-11ea-1631-153e3466c75c
using Pkg
#Pkg.activate(expanduser("~/.julia/dev/SR2StanPluto"))

# ╔═╡ d65dd2b2-fc58-11ea-2300-4db47ec9a789
begin
	# Notebook specific
	using GLM
	
	# Graphics related
	using GLMakie
	using LaTeXStrings

	# Graphs related
	using GraphMakie
	using Makie
	using Graphs
	using GraphMakie.NetworkLayout

	# Causal inference support
	using CausalInference

	# Stan specific
	using StanQuap
	using StanSample
	
	# Project support libraries
	using StatisticalRethinking: SR, sr_datadir, scale!, PRECIS
	using RegressionAndOtherStories
end

# ╔═╡ 645d4df3-af64-489b-b2b0-e710d8917680
md" ## 5.2 - Masked relationships."

# ╔═╡ 234d835c-b651-4b16-9f2e-986eda90a1a8
md"##### Set page layout for notebook."

# ╔═╡ fbc882d4-18b0-4f08-a1b1-ec4c4f78635d
html"""
<style>
	main {
		margin: 0 auto;
		max-width: 3500px;
    	padding-left: max(80px, 0%);
    	padding-right: max(200px, 38%);
	}
</style>
"""

# ╔═╡ 9c410a0d-30dd-4b46-b7cb-8892df94fb14
#Pkg.activate(expanduser("~/.julia/dev/SR2StanPluto"))

# ╔═╡ b26424bf-d206-4fb1-a2ab-222a8ffb80c7
md" ### Julia code snippet 5.28"

# ╔═╡ 06c94367-0b94-4aad-9130-01e0770ec821
begin
	df = CSV.read(sr_datadir("milk.csv"), DataFrame; delim=';')
	df.lmass = log.(df.mass)
	df = filter(row -> !(row[:neocortex_perc] == "NA"), df)
	df.neocortex_perc = parse.(Float64, df.neocortex_perc)
	scale_df_cols!(df, [:kcal_per_g, :neocortex_perc, :lmass])
end;

# ╔═╡ 42777e16-30de-4e4e-8d90-0a4c42e2a5b3
stan_5_5_draft = "
data {
 int < lower = 1 > N; // Sample size
 vector[N] K; // Outcome
 vector[N] NC; // Predictor
}
parameters {
 real a; // Intercept
 real bN; // Slope (regression coefficients)
 real < lower = 0 > sigma;    // Error SD
}
model {
  vector[N] mu;               // mu is a vector
  a ~ normal(0, 1);           //Priors
  bN ~ normal(0, 1);
  sigma ~ exponential(1);
  mu = a + bN * NC;
  K ~ normal(mu , sigma);     // Likelihood
}
";

# ╔═╡ 5f478a40-3e55-4f49-9d90-6de96aeaf92d
md"##### Define the SampleModel, etc."

# ╔═╡ cb3c4aea-7b3b-4c93-b807-b4393d7d0b4c
begin
	m5_5_drafts = SampleModel("m5.5.draft", stan_5_5_draft);
	m5_5_data = Dict("N" => size(df, 1), "NC" => df.neocortex_perc_s,
		"K" => df.kcal_per_g_s);
	rc5_5_drafts = stan_sample(m5_5_drafts, data=m5_5_data)
	success(rc5_5_drafts) && describe(rc5_5_drafts, [:a, :bN, :sigma])
end

# ╔═╡ a23527fb-8e69-48e4-934b-df9d01dbbc0a
if success(rc5_5_drafts)
	post5_5_drafts_df = read_samples(m5_5_drafts, :dataframe)
	model_summary(post5_5_drafts_df, [:a, :bN, :sigma])
end

# ╔═╡ eb13b755-0024-45fc-ab03-3e05c2a2b3b7
let
	if success(rc5_5_drafts)
		f = Figure(resolution=default_figure_resolution)
		ax = Axis(f[1, 1]; title="m5.5.drafts: a ~ Normal(0, 1), bN ~ Normal(0, 1)")
		x = -2:0.01:2
		for j in 1:100
			y = post5_5_drafts_df[j, :a] .+ post5_5_drafts_df[j, :bN]*x
			lines!(x, y, color=:lightgrey)
		end
		f
	end
end

# ╔═╡ 9f39524d-e4b0-4909-97a0-059bf46386f5
md"### Julia code snippet 5.35"

# ╔═╡ b35b41bd-8752-4b13-8745-7c24754f6768
stan5_5_1 = "
data {
 int < lower = 1 > N; // Sample size
 vector[N] K; // Outcome
 vector[N] NC; // Predictor
}

parameters {
 real a; // Intercept
 real bN; // Slope (regression coefficients)
 real < lower = 0 > sigma;    // Error SD
}

model {
  vector[N] mu;               // mu is a vector
  a ~ normal(0, 0.2);           //Priors
  bN ~ normal(0, 0.5);
  sigma ~ exponential(1);
  mu = a + bN * NC;
  K ~ normal(mu , sigma);     // Likelihood
}
";

# ╔═╡ ec590c54-67fc-4d9f-a7bb-f1ec0b126a7f
md"### Julia code snippet 5.36"

# ╔═╡ b1a7b82a-a981-42fc-9583-3899ba96fe21
let
	data = Dict("N" => size(df, 1), "NC" => df[!, :neocortex_perc_s],
		"K" => df[!, :kcal_per_g_s]);
	global m5_5_1s = SampleModel("m5.5.1", stan5_5_1);
	global rc5_5_1s = stan_sample(m5_5_1s; data)
	success(rc5_5_1s) && describe(m5_5_1s, [:a, :bN, :sigma])
end

# ╔═╡ 51abae98-54ba-49f8-8da1-1952f31353e8
begin
	post5_5_1s_df = read_samples(m5_5_1s, :dataframe)
	ms5_5_1s = model_summary(post5_5_1s_df, [:a, :bN, :sigma])
end

# ╔═╡ dd708337-e867-48c6-a6b3-0478c8b3e8bf
stan5_5_2 = "
data {
 int < lower = 1 > N; // Sample size
 vector[N] K; // Outcome
 vector[N] LM; // Predictor
}

parameters {
 real a; // Intercept
 real bLM; // Slope (regression coefficients)
 real < lower = 0 > sigma;    // Error SD
}

model {
  vector[N] mu;               // mu is a vector
  a ~ normal(0, 0.2);           //Priors
  bLM ~ normal(0, 0.5);
  sigma ~ exponential(1);
  mu = a + bLM * LM;
  K ~ normal(mu , sigma);     // Likelihood
}
";

# ╔═╡ cdbc2c0d-6b74-4765-9ce2-58e4b44adc27
md"#### Define the SampleModel, etc."

# ╔═╡ bd37996e-4843-42e0-9c5f-6425ecb0f0cd
let
	data = Dict("N" => size(df, 1), "LM" => df[!, :lmass_s],
		"K" => df[!, :kcal_per_g_s]);
	global m5_5_2s = SampleModel("m5.5.2", stan5_5_2);
	global rc5_5_2s = stan_sample(m5_5_2s; data);
end;

# ╔═╡ 2fe175d3-f3f1-45f3-8640-87a40456189d
begin
	post5_5_2s_df = read_samples(m5_5_2s, :dataframe)
	ms5_5_2s = model_summary(post5_5_2s_df, [:a, :bLM, :sigma])
end

# ╔═╡ 9d7eff6e-50c8-41a9-8d54-f726be68f0f1
md"### Julia code snippet 5.37"

# ╔═╡ eb991545-5c3c-4044-b100-42dad0c98fda
let
	x_range = -2.2:0.01:1.6
	f = Figure(resulution=default_figure_resolution)
	ax = Axis(f[1, 1]; xlabel="neocortex percent (std)", ylabel="kcal per g (std)",
		title="Kcal_per_g vs. neocortex_perc" * "\nshowing predicted and hpd range")
	res = link(post5_5_1s_df, (r, x) -> r.a + r.bN * x, x_range)
	res = hcat(res...)
	m, l, u = estimparam(res)
	band!(x_range, l, u; color=(:grey, 0.3))
	scatter!(df.neocortex_perc_s, df.kcal_per_g_s)
	lines!(x_range, ms5_5_1s[:a, :mean] .+ ms5_5_1s[:bN, :mean] .* x_range)
	ax = Axis(f[1, 2];  xlabel="log body mass (std)", ylabel="kcal per g (std)",
		title= "Kcal_per_g vs. log body mass" * "\nshowing predicted and hpd range")
	res = link(post5_5_2s_df, (r, x) -> r.a + r.bLM * x, x_range)
	res = hcat(res...)
	m, l, u = estimparam(res)
	band!(x_range, l, u; color=(:grey, 0.3))
	scatter!(df.lmass_s, df.kcal_per_g_s)	
	lines!(x_range, ms5_5_2s[:a, :mean] .+ ms5_5_2s[:bLM, :mean] .* x_range)
	f
end

# ╔═╡ 948613ed-57ac-49a7-b758-97edecc20e1e
md"### Julia code snippet 5.38"

# ╔═╡ Cell order:
# ╟─645d4df3-af64-489b-b2b0-e710d8917680
# ╟─234d835c-b651-4b16-9f2e-986eda90a1a8
# ╠═fbc882d4-18b0-4f08-a1b1-ec4c4f78635d
# ╠═16ddb41a-fc59-11ea-1631-153e3466c75c
# ╠═9c410a0d-30dd-4b46-b7cb-8892df94fb14
# ╠═d65dd2b2-fc58-11ea-2300-4db47ec9a789
# ╟─b26424bf-d206-4fb1-a2ab-222a8ffb80c7
# ╠═06c94367-0b94-4aad-9130-01e0770ec821
# ╠═42777e16-30de-4e4e-8d90-0a4c42e2a5b3
# ╟─5f478a40-3e55-4f49-9d90-6de96aeaf92d
# ╠═cb3c4aea-7b3b-4c93-b807-b4393d7d0b4c
# ╠═a23527fb-8e69-48e4-934b-df9d01dbbc0a
# ╠═eb13b755-0024-45fc-ab03-3e05c2a2b3b7
# ╟─9f39524d-e4b0-4909-97a0-059bf46386f5
# ╠═b35b41bd-8752-4b13-8745-7c24754f6768
# ╟─ec590c54-67fc-4d9f-a7bb-f1ec0b126a7f
# ╠═b1a7b82a-a981-42fc-9583-3899ba96fe21
# ╠═51abae98-54ba-49f8-8da1-1952f31353e8
# ╠═dd708337-e867-48c6-a6b3-0478c8b3e8bf
# ╟─cdbc2c0d-6b74-4765-9ce2-58e4b44adc27
# ╠═bd37996e-4843-42e0-9c5f-6425ecb0f0cd
# ╠═2fe175d3-f3f1-45f3-8640-87a40456189d
# ╟─9d7eff6e-50c8-41a9-8d54-f726be68f0f1
# ╠═eb991545-5c3c-4044-b100-42dad0c98fda
# ╟─948613ed-57ac-49a7-b758-97edecc20e1e
