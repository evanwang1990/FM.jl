@defstruct FMmodel (
  w0::Float64                = 0.0,
  w::Vector{Float64}         = Vector{Float64}(),
  v::Array{Float64}          = Array{Float64}(),

  # controls
  (SOLVER::String            = "TDAP", SOLVER in ["ALS" "MCMC" "SGD" "BGD" "FTRL" "TDAP"]),
  (TASK::String              = "CLASSIFICATION", TASK in ["CLASSIFICATION" "REGRESSION"]),
  (nthreads::Int             = 1, nthreads >= 1),
  (num_attribute::Int        = 1, num_attribute > 0),
  k0::Bool                   = true,
  k1::Bool                   = true,
  (num_factor::Int           = 2, num_factor >= 0),
  (l1_regw::Float64          = 0.0, l1_regw >= 0),
  (l1_regv::Float64          = 0.0, l1_regv >= 0),
  (l2_regw::Float64          = 0.0, l2_regw >= 0),
  (l2_regv::Float64          = 0.0, l2_regv >= 0),
  (l2_reg0::Float64          = 0.0, l2_reg0 >= 0),
  init_mean::Float64         = 0.0,
  (init_stdev::Float64       = 0.0, init_stdev >= 0),

  # temporary
  m_sum::Vector{Float64}     = Vector{Float64}(),
  m_sum_sqr::Vector{Float64} = Vector{Float64}()
)

function ModelInit(model::FMmodel)
  model.w = zeros(Float64, model.num_attribute)
  model.v = zeros(Float64, (model.num_factor, model.num_attribute))
  model.m_sum = zeros(Float64, model.num_factor)
  model.m_sum_sqr = zeros(Float64, model.num_factor)
end
