### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ 859783d0-73c9-4d1a-aab7-1d1bc474389e
using Pkg

# ╔═╡ c80881ad-605b-40fc-a492-d253fef966c8
#Pkg.activate(expanduser("~/.julia/dev/SR2StanPluto"))

# ╔═╡ ba53534c-c088-4b75-a220-36c09b375978
begin
    # General packages
    using LaTeXStrings

	# Graphics related packages
	using CairoMakie
	
	# Stan related packages
	using StanSample
	using StanQuap

	# Project functions
	using StatisticalRethinking: sr_datadir
	using RegressionAndOtherStories
end

# ╔═╡ 00d5774b-5ef0-4d01-b21d-1749beec466a
md"## Chapter 4.3 Gaussian model of height."

# ╔═╡ bd8e4305-bb79-409b-9930-e11e579b8cd0
md"##### Set page layout for notebook."

# ╔═╡ da00c7fe-43ff-4e3a-ab43-0dfd9444f779
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

# ╔═╡ 0f2f43f6-d3f6-43aa-9624-d2be810a261b
md"### Julia code snippet 4.7"

# ╔═╡ 3f3a2f1b-6f62-4bab-848b-51ec38ad3917
howell1 = CSV.read(sr_datadir("Howell1.csv"), DataFrame)

# ╔═╡ 48f8793b-6e62-49c2-8a18-83d9de4126f7
md"### Julia code snippet 4.8"

# ╔═╡ 68cbc3d5-2f4f-4ffc-b111-c1e519719632
describe(howell1)

# ╔═╡ b7eac1d2-68b1-4b09-9b83-c005960d0ca4
md"### Julia code snippet 4.9"

# ╔═╡ 09b05af8-1bb9-4dff-afc1-26ba5776aa89
describe(howell1)

# ╔═╡ e2a02bb2-046a-490f-bc1c-66e6a849d581
md"### Julia code snippet 4.10"

# ╔═╡ a10abf80-e56c-43d2-b1a7-28e4ef703ffc
howell1.height

# ╔═╡ cdd81993-c538-4df2-a75d-1c86b9a22a70
md"### Julia code snippet 4.11"

# ╔═╡ 591eeff9-52fd-4f9f-8a8a-10d94e49d89c
d2 = howell1[howell1.age .>= 18,:];

# ╔═╡ 4bef221e-4b21-4d21-9f63-75238a0afa0b
md"### Julia code snippet 4.12"

# ╔═╡ 298cb966-7a89-495f-9665-606612523a6f
let
	f = Figure(resolution=default_figure_resolution)
	ax = Axis(f[1, 1];)
	x = 100:0.1:250
	lines!(x, pdf.(Normal(178, 20), x))
	f
end

# ╔═╡ a95a8a87-a003-4053-b800-16e880cac661
md"### Julia code snippet 4.13"

# ╔═╡ 2d816327-a0c3-46b4-8cbb-fd1cba7187b3
let
	f = Figure(resolution=default_figure_resolution)
	ax = Axis(f[1, 1];)
	x = 0:0.1:50
	lines!(pdf.(Uniform(0, 50), x))
	f
end

# ╔═╡ ad0f5641-2f28-4de3-a9d4-f22c6b9b9e4d
md"### Julia code snippet 4.14"

# ╔═╡ 17553216-b97b-434e-b7a4-3ace17ce2f61
let
	sample_mu = rand(Normal(178, 20), 10000)
	sample_sigma = rand(Uniform(0, 50), 10000)
	prior_h = [rand(Normal(sample_mu[i], sample_sigma[i]))[1] for i in 1:10000]
	f = Figure(resolution=default_figure_resolution)
	ax = Axis(f[1, 1]; title="Prior h", xlabel="h")
	density!(prior_h)
	f	
end

# ╔═╡ 9ab25a70-8e23-498b-84c0-cc3fad317188
md"### Julia code snippet 4.15"

# ╔═╡ c366fcaf-0898-4e00-a0b0-ccd27837a67b
let
    sample_μ = rand(Normal(178, 100), 10000)
	sample_σ = rand(Uniform(0, 50), 10000)
    prior_h = [rand(Normal(μ, σ)) for (μ, σ) in zip(sample_μ, sample_σ)]
	f = Figure(resolution=default_figure_resolution)
	ax = Axis(f[1, 1];)
	density!(prior_h)
	vlines!([0, 272])
	f
end

# ╔═╡ 5fb479c7-6f97-44b4-b815-7fc38c7d1c5b
md"### Julia code snippet 4.16"

# ╔═╡ 5c68fc71-42f3-4198-b661-b42b4b1a5cb3
stan4_1 = "
data {
  int N;
  real<lower=0> height[N];
}
parameters {
  real<lower=0> sigma;
  real<lower=0,upper=250> mu;
}
model {
  // Priors for mu and sigma
  mu ~ normal(178, 20);
  sigma ~ uniform(0 , 50);

  // Observed heights
  height ~ normal(mu, sigma);
}
";


# ╔═╡ 33ace559-31ab-4513-a8eb-06e3a8c96cc6
let
	data = (N = length(d2.height), height = d2.height)
	init = (mu = 180.0, sigma = 10.0)
	global q4_1s, m4_1s, o4_1s = stan_quap("m4.1s", stan4_1; data, init);
	
	if q4_1s.converged  
	  quap4_1s_df = sample(q4_1s)          # DataFrame with samples
	  model_summary(quap4_1s_df, [:mu, :sigma])
	end
end

# ╔═╡ e88b889a-ef7a-42ac-8626-59e4f72dd8df
post4_1s = read_samples(m4_1s, :dataframe)

# ╔═╡ 77ae1357-ccee-4eb3-88c8-573582aa451b
let
	f = Figure(resolution=default_figure_resolution)
    size = 10_000
	    
	ax = Axis(f[1, 1]; title="mu ~ rand(Normal(178, 20), $size)", xlabel="μ")
	xlims!(0, 300)
    prior_μ = rand(Normal(178, 20), size)
    density!(prior_μ)
	
	ax = Axis(f[1, 2]; title="sigma ~ rand(Uniform(0, 50), $size)", xlabel="σ")
	xlims!(-10, 60)
	prior_σ = rand(Uniform(0, 50), size)
    density!(prior_σ)

	ax = Axis(f[2, 1]; title="h ~ rand(Normal(mu, sigma), $size)")
	xlims!(0, 300)
	sample_mu = rand(Normal(178, 20), size)
	sample_sigma = rand(Uniform(0, 50), size)
	prior_h = [rand(Normal(sample_mu[i], sample_sigma[i]))[1] for i in 1:size]
    density!(prior_h)
	
	ax = Axis(f[2, 2]; title="mu ~ rand(Normal(178, 100), $size)\nh ~ rand(Normal(mu, sigma), $size)")
	xlims!(-200, 500)
	sample_mu = rand(Normal(178, 100), size)
	sample_sigma = rand(Uniform(0, 50), size)
	prior_h = [rand(Normal(sample_mu[i], sample_sigma[i]))[1] for i in 1:size]
    density!(prior_h)

	ax = Axis(f[3, 1]; title="Posterior h")
	xlims!(0, 300)
    density!(post4_1s.mu)
	
	ax = Axis(f[3, 2]; title="Posterior sigma")
	xlims!(-10, 60)
    density!(post4_1s.sigma)

    f
end

# ╔═╡ df20a9af-49ea-442f-9975-030474dec81c
let
    global μ_list = range(150, 160; length=100)
    global σ_list = range(7, 9; length=100)
    log_likelihood = [
        sum(logpdf.(Normal(μ, σ), d2.height))
            for μ ∈ μ_list, σ ∈ σ_list
    ]
    log_prod = log_likelihood .+ [
        logpdf.(Normal(178, 20), μ) + logpdf(Uniform(0, 50), σ)
            for μ ∈ μ_list, σ ∈ σ_list
    ];

    max_prod = maximum(log_prod)
    global prob = @. exp(log_prod - max_prod);
end

# ╔═╡ 5a89d9dd-1332-457b-ad1e-408aa1ec5b1f
md"### Julia code snippet 4.17"

# ╔═╡ bf5a275c-895a-4863-aa87-85c33f66fe18
let
	f = Figure(resolution=default_figure_resolution)
	ax = Axis(f[1, 1]; title="Contour plot")
	contour!(μ_list, σ_list, prob)
	f
end

# ╔═╡ a62777e2-bf00-47de-b397-a3df0dff93d5
md"### Julia code snippet 4.18"

# ╔═╡ de78a53f-76b4-41ad-b543-56c14f09171e
let
	f = Figure(resolution=default_figure_resolution)
	ax = Axis(f[1, 1]; title="Heatmap plot")
	heatmap!(μ_list, σ_list, prob)
	f
end

# ╔═╡ 5b4c59f3-87b5-48ff-a48d-4e61a891d88f
md"### Julia code snippet 4.19 & 4.20"

# ╔═╡ 590f7b71-cbf2-4d6e-bddb-a8cc3afd8366
let
	f = Figure(resolution=default_figure_resolution)
	ax = Axis(f[1, 1];)
    indices = collect(Iterators.product(1:length(μ_list), 1:length(σ_list)));
    sample_idx = wsample(vec(indices), vec(prob), 10_000; replace=true)
    global sample_μs = μ_list[first.(sample_idx)]
    global sample_σs = σ_list[last.(sample_idx)]
	scatter!(sample_μs, sample_σs; alpha=0.1)
	f
end

# ╔═╡ 72ce105b-48a7-4eb7-a846-accae77d7e3b
md"### Julia code snippet 4.21"

# ╔═╡ 2db4ec20-7321-483f-a61e-133420c4e20d
begin
	f = Figure(resolution=default_figure_resolution)
	ax = Axis(f[1, 1];)
    p1 = Makie.density!(sample_μs)
	ax = Axis(f[2, 1];)
    p2 = Makie.density!(sample_σs)
    f
end

# ╔═╡ f55e104d-6674-48f7-b4a4-62b2f426a9eb
md"### Julia code snippet 4.22"

# ╔═╡ 33d33e81-c4a2-47d0-a2cf-1a7e2ee72543
hpdi(sample_μs, alpha=0.11)

# ╔═╡ a5740f3f-a3f9-424a-af24-110a983801b7
hpdi(sample_σs, alpha=0.11)

# ╔═╡ 061773f3-f360-43fb-ac65-012a674be330
md"### Julia code snippet 4.23"

# ╔═╡ 5562abd5-c303-4651-b08a-cdc4eda424f3
d3 = sample(d2.height, 20);

# ╔═╡ a742d704-82f2-41e0-a124-5d7ac32ca75e
md"### Julia code snippet 4.24"

# ╔═╡ 740b6299-5a58-4f61-a80b-606ab273129f
let
	f = Figure(resolution=default_figure_resolution)
	ax = Axis(f[1, 1])
	#xlims!(100, 200)
    log_likelihood = [
        sum(logpdf.(Normal(μ, σ), d3))
            for μ ∈ μ_list, σ ∈ σ_list
    ]
    log_prod = log_likelihood .+ [
        logpdf.(Normal(178, 20), μ) + logpdf(Uniform(0, 50), σ)
            for μ ∈ μ_list, σ ∈ σ_list
    ]

    max_prod = maximum(log_prod)
    prob2 = @. exp(log_prod - max_prod)

    indices = collect(Iterators.product(1:length(μ_list), 1:length(σ_list)));
    sample2_idx = wsample(vec(indices), vec(prob2), 10_000; replace=true)
    global sample2_μ = μ_list[first.(sample2_idx)]
    global sample2_σ = σ_list[last.(sample2_idx)]

    Makie.scatter!(sample2_μ, sample2_σ; alpha=0.1)
	f
end

# ╔═╡ 2c393bee-cb19-43e6-9d7a-0530e701215e
md"### Julia code snippet 4.25"

# ╔═╡ 82c707a2-0340-430b-ab4f-624116610dec
let
	f = Figure(resolution=default_figure_resolution)
	ax = Axis(f[1, 1]; title="Normal")
    density!(sample2_σ)
    μ = mean(sample2_σ)
    σ = std(sample2_σ)
	x = 6:0.1:10
    lines!(pdf.(Normal(μ, σ), x))
	f
end

# ╔═╡ bb88b854-f4ee-482b-987f-9d67ff5ed446
md"### Julia code snippet 4.26"

# ╔═╡ a259b208-b7ec-4e62-8aec-cb64b46fb9f6
md"##### Reuse `d2` from earlier."

# ╔═╡ 32d25dc8-9c78-4625-960a-e76969198083
md"### Julia code snippet 4.27"

# ╔═╡ 75f4a379-f0f9-4e87-83a8-b3e10dc179e0
m4_1_1 = "
data {
    int N;
    vector[N] height;
}
parameters {
    real mu;
    real<lower=0> sigma;
}
model {
    mu ~ normal(178, 20);
    sigma ~ uniform(0, 50);
    height ~ normal(mu, sigma);
}";

# ╔═╡ 29bbfb0d-05b0-4ef2-8548-709cf188b26f
let
	data = (N = length(d2.height), height=d2.height)
    global m4_1_1s = SampleModel("m4_1s", m4_1_1)
    global rc4_1_1s = stan_sample(m4_1_1s; data)
end;

# ╔═╡ 3a08dde3-221c-428b-b532-ba21b4e00c7b
md"### Julia code snippet 4.28"

# ╔═╡ 5e6b8c7b-b032-46a5-b26e-190dda659ea8
if success(rc4_1_1s)
    chns4_1_1s = read_samples(m4_1_1s, :mcmcchains)
end

# ╔═╡ 39d63830-404b-4b38-a5d0-22028260a064
md"### Julia code snippet 4.29"

# ╔═╡ b6fffbc4-5a39-4d94-8115-5f23aa14828d
describe(chns4_1_1s; q=[0.055, 0.945])

# ╔═╡ afbd389f-4887-45ac-b6e8-8914f5fce6d9
md"### Julia code snippet 4.30"

# ╔═╡ f2215854-2cf0-4d03-b3cf-48c4a0234c19
let
	data = (N=length(d2.height), height=d2.height)
    init = (mu=mean(d2.height), sigma=std(d2.height))
    rc4_1_2s = stan_sample(m4_1_1s; data, init)
    if success(rc4_1_2s)
        chns4_1_2s = read_samples(m4_1_1s, :mcmcchains)
    end
end

# ╔═╡ fa1037ef-d681-4cf3-9a78-2fd630d5e4c2
md"### Julia code snippet 4.31"

# ╔═╡ fc1d53c0-dc27-4559-be5c-6787f88700a8
stan4_2 = "
// Inferring the mean and std
data {
  int N;
  real<lower=0> h[N];
}
parameters {
  real<lower=0> sigma;
  real<lower=0,upper=250> mu;
}
model {
  // Priors for mu and sigma
  mu ~ normal(178, 1.0);
  sigma ~ uniform(0 , 50);

  // Observed heights
  h ~ normal(mu, sigma);
}";

# ╔═╡ 8b6b8c45-a19a-46d4-89c4-a768472fac1c
let
    data = Dict(:N => length(d2.height), :h => d2.height)
    init = Dict(:mu => 180.0, :sigma => 50.0)
    global q4_2s, m4_2s, _ = stan_quap("m4.2s", stan4_2; data, init)
    if !isnothing(m4_2s)
        global post4_2s_df = read_samples(m4_2s, :dataframe)
        part4_2s = read_samples(m4_2s, :particles)
    end
end

# ╔═╡ 9b024975-82a4-47c8-88e9-d12c84388ef0
if !isnothing(q4_2s)
    quap4_2s_df = sample(q4_2s)
    model_summary(quap4_2s_df, [:mu, :sigma])
end

# ╔═╡ a7ab6549-5318-4cd1-8905-697718ac33c8
begin
    chns4_2s = read_samples(m4_2s, :mcmcchains)
    describe(chns4_2s; q=[0.055, 0.945])
end

# ╔═╡ b4a5cab9-88af-4b9b-b28f-5c42b09f26a3
md"### Julia code snippet 4.32"

# ╔═╡ 7165d2f1-25f8-4d8b-a48e-3d2a3b607d52
cov(hcat(chns4_2s[:mu], chns4_2s[:sigma]))

# ╔═╡ c8d3d6ce-dee1-4874-a657-a1ed65d436ab
md"### Julia code snippet 4.33"

# ╔═╡ 5daaed2b-1a6c-4947-8f73-7ca99c11c5c6
let
    c = cov(hcat(chns4_2s[:mu], chns4_2s[:sigma]))
    cov2cor(c, diag(c))
end

# ╔═╡ a8c25ced-ff75-455e-bb99-b46e19f74157
md"### Julia code snippet 4.34"

# ╔═╡ 4588a47b-98e4-4ee4-abc9-4402337a1acf
begin
    samp_df = sample(post4_2s_df, 10_000)
    first(samp_df, 5)
end

# ╔═╡ ee59d741-e702-4dbc-8207-b403731f6392
md"### Julia code snippet 4.35"

# ╔═╡ cbd63f89-db04-4fee-a2b7-a892a5635c93
model_summary(samp_df, [:mu, :sigma])

# ╔═╡ a6b2b528-5743-4f3e-8964-79a08593c092
md"### Julia code snippet 4.36"

# ╔═╡ efe78641-ae87-46dd-be6f-e18cbfa0b5ca
let
    data = hcat(chns4_2s[:mu], chns4_2s[:sigma])
    μ = mean(data, dims=1)
    σ = cov(data)
    mvn = MvNormal(vec(μ), σ)
    post = rand(mvn, 10_000);
    mvn
end

# ╔═╡ Cell order:
# ╟─00d5774b-5ef0-4d01-b21d-1749beec466a
# ╟─bd8e4305-bb79-409b-9930-e11e579b8cd0
# ╠═da00c7fe-43ff-4e3a-ab43-0dfd9444f779
# ╠═859783d0-73c9-4d1a-aab7-1d1bc474389e
# ╠═c80881ad-605b-40fc-a492-d253fef966c8
# ╠═ba53534c-c088-4b75-a220-36c09b375978
# ╟─0f2f43f6-d3f6-43aa-9624-d2be810a261b
# ╠═3f3a2f1b-6f62-4bab-848b-51ec38ad3917
# ╟─48f8793b-6e62-49c2-8a18-83d9de4126f7
# ╠═68cbc3d5-2f4f-4ffc-b111-c1e519719632
# ╟─b7eac1d2-68b1-4b09-9b83-c005960d0ca4
# ╠═09b05af8-1bb9-4dff-afc1-26ba5776aa89
# ╟─e2a02bb2-046a-490f-bc1c-66e6a849d581
# ╠═a10abf80-e56c-43d2-b1a7-28e4ef703ffc
# ╟─cdd81993-c538-4df2-a75d-1c86b9a22a70
# ╠═591eeff9-52fd-4f9f-8a8a-10d94e49d89c
# ╟─4bef221e-4b21-4d21-9f63-75238a0afa0b
# ╠═298cb966-7a89-495f-9665-606612523a6f
# ╟─a95a8a87-a003-4053-b800-16e880cac661
# ╠═2d816327-a0c3-46b4-8cbb-fd1cba7187b3
# ╟─ad0f5641-2f28-4de3-a9d4-f22c6b9b9e4d
# ╠═17553216-b97b-434e-b7a4-3ace17ce2f61
# ╟─9ab25a70-8e23-498b-84c0-cc3fad317188
# ╠═c366fcaf-0898-4e00-a0b0-ccd27837a67b
# ╟─5fb479c7-6f97-44b4-b815-7fc38c7d1c5b
# ╠═5c68fc71-42f3-4198-b661-b42b4b1a5cb3
# ╠═33ace559-31ab-4513-a8eb-06e3a8c96cc6
# ╠═e88b889a-ef7a-42ac-8626-59e4f72dd8df
# ╠═77ae1357-ccee-4eb3-88c8-573582aa451b
# ╠═df20a9af-49ea-442f-9975-030474dec81c
# ╟─5a89d9dd-1332-457b-ad1e-408aa1ec5b1f
# ╠═bf5a275c-895a-4863-aa87-85c33f66fe18
# ╟─a62777e2-bf00-47de-b397-a3df0dff93d5
# ╠═de78a53f-76b4-41ad-b543-56c14f09171e
# ╟─5b4c59f3-87b5-48ff-a48d-4e61a891d88f
# ╠═590f7b71-cbf2-4d6e-bddb-a8cc3afd8366
# ╟─72ce105b-48a7-4eb7-a846-accae77d7e3b
# ╠═2db4ec20-7321-483f-a61e-133420c4e20d
# ╟─f55e104d-6674-48f7-b4a4-62b2f426a9eb
# ╠═33d33e81-c4a2-47d0-a2cf-1a7e2ee72543
# ╠═a5740f3f-a3f9-424a-af24-110a983801b7
# ╟─061773f3-f360-43fb-ac65-012a674be330
# ╠═5562abd5-c303-4651-b08a-cdc4eda424f3
# ╟─a742d704-82f2-41e0-a124-5d7ac32ca75e
# ╠═740b6299-5a58-4f61-a80b-606ab273129f
# ╟─2c393bee-cb19-43e6-9d7a-0530e701215e
# ╠═82c707a2-0340-430b-ab4f-624116610dec
# ╟─bb88b854-f4ee-482b-987f-9d67ff5ed446
# ╟─a259b208-b7ec-4e62-8aec-cb64b46fb9f6
# ╟─32d25dc8-9c78-4625-960a-e76969198083
# ╠═75f4a379-f0f9-4e87-83a8-b3e10dc179e0
# ╠═29bbfb0d-05b0-4ef2-8548-709cf188b26f
# ╟─3a08dde3-221c-428b-b532-ba21b4e00c7b
# ╠═5e6b8c7b-b032-46a5-b26e-190dda659ea8
# ╟─39d63830-404b-4b38-a5d0-22028260a064
# ╠═b6fffbc4-5a39-4d94-8115-5f23aa14828d
# ╟─afbd389f-4887-45ac-b6e8-8914f5fce6d9
# ╠═f2215854-2cf0-4d03-b3cf-48c4a0234c19
# ╟─fa1037ef-d681-4cf3-9a78-2fd630d5e4c2
# ╠═fc1d53c0-dc27-4559-be5c-6787f88700a8
# ╠═8b6b8c45-a19a-46d4-89c4-a768472fac1c
# ╠═9b024975-82a4-47c8-88e9-d12c84388ef0
# ╠═a7ab6549-5318-4cd1-8905-697718ac33c8
# ╟─b4a5cab9-88af-4b9b-b28f-5c42b09f26a3
# ╠═7165d2f1-25f8-4d8b-a48e-3d2a3b607d52
# ╟─c8d3d6ce-dee1-4874-a657-a1ed65d436ab
# ╠═5daaed2b-1a6c-4947-8f73-7ca99c11c5c6
# ╟─a8c25ced-ff75-455e-bb99-b46e19f74157
# ╠═4588a47b-98e4-4ee4-abc9-4402337a1acf
# ╟─ee59d741-e702-4dbc-8207-b403731f6392
# ╠═cbd63f89-db04-4fee-a2b7-a892a5635c93
# ╟─a6b2b528-5743-4f3e-8964-79a08593c092
# ╠═efe78641-ae87-46dd-be6f-e18cbfa0b5ca
