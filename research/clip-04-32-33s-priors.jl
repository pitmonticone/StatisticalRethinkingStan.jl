
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
  using StanOptimize
	using StatisticalRethinking
end

md"## Clip-04-32-33s.jl"

md"### Snippet 4.26"

begin
	df = CSV.read(sr_datadir("Howell1.csv"), DataFrame; delim=';')
	df = filter(row -> row[:age] >= 18, df);
end;

m4_2 = "
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
  mu ~ normal(178, 20);
  sigma ~ uniform( 0 , 50 );

  // Observed heights
  h ~ normal(mu, sigma);
}
";

md"### Snippet 4.31"

m4_2s = SampleModel("p4_2s", m4_2);

prior4_2_data = Dict("N" => 0, "h" => []);
rc = stan_sample(m4_2s; data=prior4_2_data);

if success(rc)
  priors4_2s = read_samples(m4_2s; output_format=:dataframe)
  precis(priors4_2s)
end

md"## End of clip-04-32-34s.jl"

