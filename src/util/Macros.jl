"""A convenient macro copied from Mocha.jl that could be used to define structs
with default values and type checks. For example
```julia
@defstruct MyStruct Any (
  field1 :: Int = 0,
  (field2 :: AbstractString = "", !isempty(field2))
)
```
The macro will define a constructor without keyword arguments and `set` function.
We can use the `set` function to assign a field's value and check if the value is
valid.
"""
macro defstruct(name, fields)
  @assert(isa(name, Symbol) || isa(name, Expr),
  "name should be a Symbol")
  if isa(name, Expr)
    @assert(name.head == :(<:) && length(name.args) == 2 && all([isa(m) for m in name.args]),
    "name should be of form 'Name <: SuperType'")
    name, super_type = name.args
  else
    super_type = :Any
  end

  @assert(isa(fields, Expr) && fields.head == :tuple)

  field_names       = Vector{Symbol}(0)
  field_defs        = Vector{Expr}(0)
  field_defaults    = Vector{Expr}(0)
  field_asserts     = Vector{Pair{String, Expr}}(0)

  for field in fields.args
    if field.head == :tuple
      @assert(length(field.args) == 2, "length of tuple should be 2")
      push!(field_asserts, Pair(string(field.args[1].args[1].args[1]), field.args[2]))
      # push!(field_asserts, esc(field.args[2]))
      field = field.args[1]
    end
    @assert(field.head == :(=), string(field) * "should have default value")
    push!(field_defaults, esc(field))
    field = field.args[1]
    push!(field_defs, field)
    push!(field_names, field.args[1])
  end

  type_body = Expr(:block, field_defs...)
  struct_body = Expr(:block, field_defaults..., Expr(:call, :new, field_names...))
  asserts   = Expr(:call, :(Dict{String, Expr}), field_asserts...)
  set_ = esc(Symbol("set_" * string(name)))
  set = esc(Symbol("set" * string(name)))
  inner_func = Expr(:call, esc(:tmp), Expr(:parameters, Expr(:kw, :object, nothing), Expr(:kw, :(param::String), nothing), Expr(:kw, :(value::Any), nothing)))
  # outer_func = Expr(:(=), set, Expr(:call, set_))
  outer_func = "set(object::$(string(name)), param::String, value::Any) = set_" * string(name) * "()(object = object, param = param, value = value)"
  quote
    type $(name) <: $(super_type)
      $type_body

      function $(name)()
        $struct_body
      end
    end

    function $(set_)()
      $(esc(:asserts)) = $asserts
      $(inner_func) = begin
        if haskey(asserts, param)
          eval(Expr(:(=), Symbol(param), value))
          @assert(eval(asserts[param]), param * " is invalid")
        end;
        setfield!(object, Symbol(param), value)
      end
      return $(esc(:tmp))
    end

    # $outer_func
    eval(parse($(esc(outer_func))))
  end
end
