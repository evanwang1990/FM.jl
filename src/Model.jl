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

function InitModel(model::FMmodel)
  model.w = zeros(Float64, model.num_attribute)
  model.v = zeros(Float64, (model.num_factor, model.num_attribute))
  model.m_sum = zeros(Float64, model.num_factor)
  model.m_sum_sqr = zeros(Float64, model.num_factor)
end


function SaveModel(model::FMmodel, file::String)
  checkPath(file)
  open(file, "w+") do io
    write(io, "FMmodel\n")
    for field in fieldnames(model)
      writeKV(io, string(field), getfield(model, field))
    end
  end
end

function LoadModel(file::String)
  checkPath(file)
  isfile(file) || error(file * " does not exist")
  open(file, "r") do io
    ftype = readline(io)
    @assert(ftype == "FMmodel\n", "the file read in is not a FMmodel output")
    for line in eachline(io)
      key, value = readKV(line)
      set(model, convert(String, key), value)
    end
  end
  return model
end

function predict(model::FMmodel, vec::SparseVector)
  pred::Float64 = 0.0
  model.k0 && pred += model.w0
  model.m_sum = zeros(model.m_sum)
  model.m_sum_sqr = zeros(model.m_sum_sqr)

  for (_idx, _val) in zip(vec.nzind, vec.nzval):
    model.k1 &&　pred += model.w[_idx] * _val
    for i in 1:model.num_factor
      _tmp = model.v[i, _idx] * _val
      model.m_sum[i] += _tmp
      model.m_sum_sqr[i] += _tmp^2
    end
  end

  for i in 1:model.num_factor
    pred += 0.5 * (model.m_sum[i] ^ 2 - model.m_sum_sqr[i])
  end

  return pred
end
