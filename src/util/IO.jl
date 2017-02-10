function write_key_value(io::IOStream, key::String, value::Union{String, Number})
  write(io, string(key, "~", string(typeof(value)), "@"))
  writedlm(io, value, ',')
end

function write_key_value(io::IOStream, key::String, value::Array)
  dims = string(size(value))
  type_ = string(typeof(value))
  if ndims(value) > 1
    value = reshape(value, (1, length(value)))
  end
  write(io, string(join([key, type_, dims], "~"), "@"))
  writedlm(io, value, ',')
end
