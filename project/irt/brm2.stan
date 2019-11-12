data {
  int<lower = 0> N;
  int<lower = 0> J;
  matrix[N,J] y;
  vector[J] ymax;
}

transformed data{
  matrix[N,J] x;
  vector[N] tmp;
  for(j in 1:J){
    tmp = y[,j];
    x[,j] = (tmp+1) / (ymax[j]+2);
  }
}

parameters {
  real<lower = 0> a[J];
  real b[J];
  real theta[N];
}

transformed parameters{
  matrix[N, J] shape1;
  matrix[N, J] shape2;
  real m;
  for(i in 1:N){
    for (j in 1:J){
      if(x[i,j] < 0) continue;
      m = a[j] * (theta[i] - b[j]) / 2.0;
      shape1[i,j] = exp(m);
      shape2[i,j] = exp(-m);
    }
  }
}

model {
  a ~ cauchy(0.5, 1);
  b ~ normal(0, 3);
  theta ~ normal(0, 1);
  for(i in 1:N){
    for(j in 1:J){
      if(x[i,j] < 0){
        // target += 0;
        continue;
      } else {
        // target += beta_lpdf(x[i,j] | shape1[i,j], shape2[i,j]);
        x[i,j] ~ beta(shape1[i,j], shape2[i,j]);
      }
      
    }
  }
}
