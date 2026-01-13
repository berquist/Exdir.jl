struct NotImplementedError <: Exception
    msg::String
end

struct IOError <: Exception
    msg::String
end

Base.showerror(io::IO, e::IOError) = print(io, "IOError: $(e.msg)")
