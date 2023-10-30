module Exdir

import YAML

export
    attributes,
    attrs,
    create_dataset,
    create_group,
    create_raw,
    delete_object,
    exdiropen,
    is_nonraw_object_directory,
    require_dataset,
    require_group,
    require_raw,
    setattrs!

include("consistency.jl")
include("constants.jl")
include("exceptions.jl")
include("mode.jl")
include("path.jl")

abstract type AbstractObject end
abstract type AbstractGroup <: AbstractObject end

struct Attribute
end

struct Object <: AbstractObject
    root_directory::String
    parent_path::String
    object_name::String
    file
    relative_path::String
    name::String

    function Object(; root_directory, parent_path, object_name, file)
        relative_path = form_relative_path(parent_path, object_name)
        name = "/" * relative_path
        new(
            root_directory,
            parent_path,
            object_name,
            file,
            relative_path,
            name
        )
    end
end

function Base.getproperty(obj::AbstractObject, sym::Symbol)
    if sym == :directory
        return joinpath(obj.root_directory, obj.relative_path)
    elseif sym == :attrs
        return Attribute()
    elseif sym == :meta
        return Attribute()
    elseif sym == :attributes_filename
        return joinpath(obj.directory, ATTRIBUTES_FILENAME)
    elseif sym == :meta_filename
        return joinpath(obj.directory, META_FILENAME)
    elseif sym == :parent
        if length(splitpath(obj.parent_path)) < 1
            return nothing
        end
        (parent_parent_path, parent_name) = splitdir(obj.parent_path)
        return Group(
            root_directory = obj.root_directory,
            parent_path = parent_parent_path,
            object_name = parent_name,
            file = obj.file,
        )
    else
        return getfield(obj, sym)
    end
end

function Base.setproperty!(obj::AbstractObject, f::Symbol, v)
    if f == :attrs
        nothing
    else
        setfield!(obj, f, v)
    end
end

function create_raw(obj::AbstractObject, name::AbstractString)
    # https://github.com/CINPLA/exdir/blob/89c1d34a5ce65fefc09b6fe1c5e8fef68c494e75/exdir/core/exdir_object.py#L238
    assert_file_open(obj.file)
    _assert_valid_name(name, obj)
    directory_name = joinpath(obj.directory, name)
    if ispath(directory_name)
        throw(IOError("'$(directory_name)' already exists in '$obj'"))
    end
    mkdir(directory_name)
    Raw(
        root_directory = obj.root_directory,
        parent_path = obj.relative_path,
        object_name = name,
        file = obj.file,
    )
end

function require_raw(obj::AbstractObject, name::AbstractString)
    assert_file_open(obj.file)
    directory_name = joinpath(obj.directory, name)
    if ispath(directory_name)
        if is_nonraw_object_directory(directory_name)
            throw(ArgumentError("Directory '$(directory_name)' already exists, but is not raw."))
        end
        return Raw(
            root_directory = obj.root_directory,
            parent_path = obj.relative_path,
            object_name = name,
            file = obj.file,
        )
    end
    create_raw(obj, name)
end

# TODO
# function parent(obj::AbstractObject)
# end

function Base.:(==)(obj::AbstractObject, other)
    # if obj.file.io_mode == OpenMode::FILE_CLOSED
    #     return false
    # end
    if !isa(obj, AbstractObject)
        false
    else
        obj.relative_path == other.relative_path &&
            obj.root_directory == other.root_directory
    end
end

function Base.print(io::IO, obj::AbstractObject)
    # if obj.file.io_mode == OpenMode.FILE_CLOSED
    #     msg = "<Closed Exdir Object>"
    # else
        msg = "<Exdir Obj '$(obj.directory)' (mode TODO)>"
    # end
    print(io, msg)
end

"""

Raw objects are simple folders with any content.

Raw objects currently have no features apart from showing their path.
"""
struct Raw <: AbstractObject
    root_directory::String
    parent_path::String
    object_name::String
    file
    relative_path::String
    name::String

    function Raw(; root_directory, parent_path, object_name, file=nothing)
        relative_path = form_relative_path(parent_path, object_name)
        name = "/" * relative_path
        new(
            root_directory,
            parent_path,
            object_name,
            file,
            relative_path,
            name
        )
    end
end

struct Dataset <: AbstractObject
    root_directory::String
    parent_path::String
    object_name::String
    file
    relative_path::String
    name::String

    data

    function Dataset(; root_directory, parent_path, object_name, file, data)
        relative_path = form_relative_path(parent_path, object_name)
        name = "/" * relative_path
        new(
            root_directory,
            parent_path,
            object_name,
            file,
            relative_path,
            name,
            data
        )
    end
end

function Base.convert(::Type{Object}, dset::Dataset)
    Object(;
        root_directory = dset.root_directory,
        parent_path = dset.parent_path,
        object_name = dset.object_name,
        file = dset.file,
    )
end

function Base.getproperty(dset::Dataset, sym::Symbol)
    if sym == :dtype
        return eltype(dset)
    # TODO
    elseif sym == :directory
        return joinpath(dset.root_directory, dset.relative_path)
    elseif sym == :attrs
        return Attribute()
    elseif sym == :meta
        return Attribute()
    elseif sym == :attributes_filename
        return joinpath(dset.directory, ATTRIBUTES_FILENAME)
    elseif sym == :meta_filename
        return joinpath(dset.directory, META_FILENAME)
    elseif sym == :parent
        if length(splitpath(dset.parent_path)) < 1
            return nothing
        end
        (parent_parent_path, parent_name) = splitdir(dset.parent_path)
        return Group(
            root_directory = dset.root_directory,
            parent_path = parent_parent_path,
            dsetect_name = parent_name,
            file = dset.file,
        )
    else
        return getfield(dset, sym)
    end
    # else
    #     return getproperty(convert(Object, dset), sym)
    # end
end

Base.collect(dset::Dataset) = collect(dset.data)
Base.iterate(dset::Dataset) = iterate(dset.data)
Base.iterate(dset::Dataset, state) = iterate(dset.data, state)
Base.length(dset::Dataset) = prod(size(dset))
Base.size(dset::Dataset) = size(dset.data)
Base.getindex(dset::Dataset, inds...) = getindex(dset.data, inds...)
Base.eltype(dset::Dataset) = eltype(dset.data)

# TODO this may fail in a gross way if value is a group/file/other Exdir type.
# Can we restrict to scalars and arrays?
function Base.setindex!(grp::AbstractGroup, value, name::AbstractString)
    assert_file_open(grp.file)
    path = name_to_asserted_group_path(name)
    parts = splitpath(path)
    if length(parts) > 1
        grp[dirname(path)][basename(path)] = value
        return nothing
    end
    if !in(name, grp)
        create_dataset(grp, name; data=value)
        return nothing
    end
    if !isa(grp[name], Dataset)
        error("Unable to assign value, $(name) already exists")
    end
    grp[name].value = value
    nothing
end

struct Group <: AbstractGroup
    root_directory::String
    parent_path::String
    object_name::String
    file
    relative_path::String
    name::String

    function Group(; root_directory, parent_path, object_name, file=nothing)
        relative_path = form_relative_path(parent_path, object_name)
        name = "/" * relative_path
        new(
            root_directory,
            parent_path,
            object_name,
            file,
            relative_path,
            name
        )
    end
end

function Base.in(name::AbstractString, grp::AbstractGroup)
    # if grp.file.io_mode == OpenMode.FILE_CLOSED
    #     return false
    # end
    if name == "."
        return true
    elseif name == ""
        return false
    else
        path = name_to_asserted_group_path(name)
        directory = joinpath(grp.directory, path)
        return is_exdir_object(directory)
    end
end

function Base.get(grp::AbstractGroup, name::AbstractString, default=nothing)
    if name in grp
        grp[name]
    else
        default
    end
end

function unsafe_dataset(grp::AbstractGroup, name)
    Dataset(
        root_directory = grp.root_directory,
        parent_path = grp.relative_path,
        object_name = name,
        file = grp.file,
        data = nothing,
    )
end

function unsafe_group(grp::AbstractGroup, name)
    Group(
        root_directory = grp.root_directory,
        parent_path = grp.relative_path,
        object_name = name,
        file = grp.file
    )
end

function Base.getindex(grp::AbstractGroup, name::AbstractString)
    assert_file_open(grp.file)
    path = name_to_asserted_group_path(name)
    parts = splitpath(path)
    if length(parts) > 1
        top_directory = parts[1]
        sub_name = joinpath(parts[2:end])
        return grp[top_directory][sub_name]
    end

    if !in(name, grp)
        error_message = "No such object: '$name' in path '$(grp.directory)'"
        throw(ArgumentError(error_message))
    end

    directory = joinpath(grp.directory, path)

    # TODO create one function that handles all Raw creation
    if is_raw_object_directory(directory)
        return Raw(
            root_directory = grp.root_directory,
            parent_path = grp.relative_path,
            object_name = name,
            file = grp.file,
        )
    end

    if !is_nonraw_object_directory(directory)
        throw(ArgumentError("Directory '$directory' is not a valid exdir object."))
    end

    meta_filename = joinpath(directory, META_FILENAME)
    meta_data = YAML.load_file(meta_filename)
    typename = meta_data[EXDIR_METANAME][TYPE_METANAME]
    if typename == DATASET_TYPENAME
        return unsafe_dataset(grp, name)
    elseif typename == GROUP_TYPENAME
        return unsafe_group(grp, name)
    else
        error_string = "Object $name has data type $typename.\nWe cannot open objects of this type."
        throw(ArgumentError(error_string))
    end
end

struct GroupIteratorState
    "Keep track of the base Group originally passed in"
    base_grp
    "Unused"
    root
    "Unused"
    current_base
    "The current object (group, dset) name we are looking at"
    current_obj_name
    "Result of collect(walkdir(grp.root_directory))"
    itr
    "Current index into itr"
    index
    "Fully-typed object"
    obj
end

# This is work on fully recursive iteration.

# # Iterate over all the objects in the group.
# function Base.iterate(grp::AbstractGroup)
#     itr = collect(walkdir(grp.root_directory))
#     # "This" directory (the passed-in group) will always be the first result
#     # and we want to ignore it.
#     if length(itr) < 2
#         return nothing
#     end
#     index = 2
#     (root, dirs, files) = itr[index]
#     @assert startswith(root, grp.root_directory)
#     @assert files == [META_FILENAME]
#     len_prefix = length(grp.root_directory)
#     current_obj_name = root[len_prefix + 1 : end]
#     state = GroupIteratorState(
#         grp,
#         root,
#         root,
#         current_obj_name,
#         itr,
#         index + 1,
#         getindex(grp, current_obj_name)
#     )
#     item = state.obj.name
#     (item, state)
# end

# # Iterate over all the objects in the group.
# function Base.iterate(grp::AbstractGroup, state)
#     # assert_file_open(grp.file)
#     if state.index <= length(state.itr)
#         (root, dirs, files) = state.itr[state.index]
#         @assert startswith(root, grp.root_directory)
#         @assert files == [META_FILENAME]
#         len_prefix = length(grp.root_directory)
#         current_obj_name = root[len_prefix + 1 : end]
#         new_state = GroupIteratorState(
#             state.base_grp,
#             state.root,
#             state.root,
#             current_obj_name,
#             state.itr,
#             state.index + 1,
#             getindex(state.base_grp, current_obj_name)
#         )
#         item = new_state.obj.name
#         (item, new_state)
#     else
#         nothing
#     end
# end

function Base.iterate(grp::AbstractGroup, dirs=nothing)
    if isnothing(dirs)
        grp_root = joinpath(grp.root_directory, grp.relative_path)
        itr = walkdir(grp_root)
        (root, dirs, files) = first(itr)
        @assert root == grp_root
        @assert files == [META_FILENAME]
    end
    isempty(dirs) ? nothing : (dirs[1], dirs[2:end])
end

Base.length(grp::AbstractGroup) = length(first(walkdir(joinpath(grp.root_directory, grp.relative_path)))[2])

function Base.delete!(grp::AbstractGroup, name::AbstractString)
    if !in(name, grp)
        # throw(KeyError("No such object '$(name)' in path '$(grp.name)'"))
        throw(KeyError(name))
    end
    @assert !isabspath(name)
    path = joinpath(grp.root_directory, grp.relative_path, name)
    @assert isdir(path)
    rm(path, recursive=true)
end
delete_object(grp::AbstractGroup, name::AbstractString) = delete!(grp, name)

struct IOError <: Exception
    msg::String
end

Base.showerror(io::IO, e::IOError) = print(io, "IOError: $(e.msg)")

struct File <: AbstractGroup
    root_directory::String
    parent_path::String
    object_name::String
    file
    relative_path::String
    name::String

    user_mode::String

    function File(; root_directory, parent_path, object_name, file, user_mode)
        relative_path = form_relative_path(parent_path, object_name)
        name = "/" * relative_path
        new(
            root_directory,
            parent_path,
            object_name,
            file,
            relative_path,
            name,
            user_mode
        )
    end

    # location::AbstractString
    # writable::Bool

    # mode::AbstractString
    # allow_remove::Bool
    # name_validation
    # plugins
end

function Base.getindex(file::File, name::AbstractString)
    path = remove_root(name)
    if length(splitpath(path)) < 1
        file
    else
        Base.getindex(convert(Group, file), path)
    end
end

Base.in(name::AbstractString, file::File) = in(remove_root(name), convert(Group, file))

function Base.convert(::Type{Group}, file::File)
    Group(;
        root_directory = file.root_directory,
        parent_path = file.parent_path,
        object_name = file.object_name,
        file = file.file,
    )
end

function Base.print(io::IO, file::File)
    msg = "<Exdir File '$(file.directory)' (mode TODO)>"
    print(io, msg)
end

const EXTENSION = ".exdir"

"""
    form_location(directory)

Prepare the given directory location for use by removing any trailing
slashes/directory signifiers, ensuring the directory ends with the `.exdir`
extension, and making the directory path absolute.
"""
function form_location(directory::AbstractString)
    normalized = if isdirpath(directory)
        dirname(directory)
    else
        directory
    end
    normalized = if splitext(normalized)[2] != EXTENSION
        normalized * EXTENSION
    else
        normalized
    end
    location = if isabspath(normalized)
        normalized
    else
        joinpath(pwd(), normalized)
    end
    location
end

# TODO should this instead correspond do
function parsemode(mode::AbstractString)
    mode == "r"  ? (writeable=false, create=false, truncate=false) :
    mode == "r+" ? (writeable=true, create=false, truncate=false) :
    mode == "a" || mode == "a+" ? (writeable=true, create=true, truncate=false) :
    mode == "w" || mode == "w+" ? (writeable=true, create=true, truncate=true) :
    throw(DomainError("invalid open mode: $mode"))
end

"""
    exdiropen(directory::AbstractString, mode::AbstractString)

Opens an ExDir tree at path `directory`.

`"r"`: Open for reading only, failing if no file exists
`"r+"`: Open for reading and writing, failing if no file exists
`"w"`/`"w+"`: Open for reading and writing, overwriting the file if it already exists
`"a"`/`"a+"`: Open for reading and writing, creating a new file if none exists, but
              preserving the existing file if one is present
"""
function exdiropen(directory::AbstractString, mode::AbstractString;
                   allow_remove=false)::Exdir.File

    location = form_location(directory)
    (writeable, create, truncate) = parsemode(mode)
    already_exists = ispath(location)
    # is_directory = isdir(location)
    should_create_directory = false
    if !create
        if !already_exists
            throw(ArgumentError("mode='r' for $location but it doesn't exist"))
        # else if !isvalid()
        #     throw(ArgumentError("mode='r' for $location but it isn't a valid ExDir tree"))
        end
    else
        if truncate
            if already_exists
                rm(location, recursive=true)
            end
        # else
        #     if allow_remove
        #         rm(location, recursive=true)
        #     else
        end
        should_create_directory = true
    end

    if should_create_directory
        # name_validation(location)
        create_object_directory(location, defaultmetadata(FILE_TYPENAME))
    end

    File(
        root_directory = location,
        parent_path = "",
        object_name = "",
        file = nothing,
        user_mode = mode
    )
end

# function exdiropen(directory::AbstractString, mode::AbstractString)
#     exdiropen(directory, mode, allow_remove=false)
# end

function Base.close(file::File)
    nothing
end

Base.keys(grp::AbstractGroup) = collect(grp)
Base.haskey(grp::AbstractGroup, name::AbstractString) = in(name, grp)
Base.values(grp::AbstractGroup) = [getindex(grp, key) for key in keys(grp)]

function Base.setindex!(attrs::Attribute, value, name::AbstractString)
end

function defaultmetadata(typename::String)
    Dict(EXDIR_METANAME => Dict(TYPE_METANAME => typename, VERSION_METANAME => 1))
end

makemetadata(typename::String) = YAML.write(defaultmetadata(typename))
makemetadata(_::Object) = throw(NotImplementedError("makemetadata not implemented for Exdir.Object"))
makemetadata(_::Dataset) = makemetadata(DATASET_TYPENAME)
makemetadata(_::Group) = makemetadata(GROUP_TYPENAME)
makemetadata(_::File) = makemetadata(FILE_TYPENAME)

# function setattrs!(f, "description", "This is a mock experiment with voltage values over time")
function setattrs!(obj, name::AbstractString, value)
    nothing
end

function attributes(object::Object)
    Attribute()
end

function attributes(dset::Dataset)
    Attribute()
end

function attributes(group::Group)
    Attribute()
end

function attributes(file::File)
    Attribute()
end

function attrs(thing)
end

function _create_group(x, name::AbstractString)
    path = name_to_asserted_group_path(name)
    if length(splitpath(path)) > 1
        (parent, pname) = splitdir(path)
        subgroup = require_group(x, parent)
        return create_group(subgroup, pname)
    end

    _assert_valid_name(path, x)

    if name in x
        throw(ArgumentError("'$name' already exists in $(x.name)"))
    end

    group_directory = joinpath(x.directory, path)
    create_object_directory(group_directory, defaultmetadata(GROUP_TYPENAME))

    Group(
        root_directory = x.root_directory,
        parent_path = x.relative_path,
        object_name = name,
        file = x.file,
    )
end

"""
    create_group(file, name)


"""
create_group(file::File, name::AbstractString) = _create_group(file, remove_root(name))

"""
    create_group(grp, name)


"""
create_group(grp::Group, name::AbstractString) = _create_group(grp, name)

function _require_group(grp, name::AbstractString)
    # assert_file_open
    path = name_to_asserted_group_path(name)

    if length(splitpath(path)) > 1
        (parent, pname) = splitdir(path)
        subgroup = require_group(grp, parent)
        return create_group(subgroup, pname)
    end

    group_directory = joinpath(grp.directory, path)

    if name in grp
        current_object = grp[name]
        if isa(current_object, Group)
            return current_object
        else
            throw(ArgumentError("An object with name '$name' already exists, but it is not a Group."))
        end
    elseif ispath(group_directory)
        throw(ArgumentError("Directory '$(group_directory)' already exists, but is not an Exdir object."))
    end

    create_group(grp, name)
end

"""
    require_group(file, name)


"""
require_group(file::File, name::AbstractString) = _require_group(file, remove_root(name))

"""
    require_group(grp, name)


"""
require_group(grp::Group, name::AbstractString) = _require_group(grp, name)


function Base.write(dset::Dataset, data)
    error("unimplemented")
end

function _prepare_write(data, attrs::AbstractDict, meta::AbstractDict)
    if isnothing(data)
        data = nothing
    elseif !isa(data, AbstractArray)
        data = collect(data)
    end
    # If plugins were implemented, they would have been applied to attrs and
    # meta rather than simply passing them through.
    (data, attrs, meta)
end

function create_dataset(grp::AbstractGroup, name::AbstractString;
                        shape=nothing,
                        dtype=nothing,
                        exact::Bool=false,
                        data=nothing,
                        fillvalue=nothing)
    # https://github.com/CINPLA/exdir/blob/89c1d34a5ce65fefc09b6fe1c5e8fef68c494e75/exdir/core/group.py#L72
    path = name_to_asserted_group_path(name)

    if length(splitpath(path)) > 1
        (parent, pname) = splitdir(path)
        subgroup = require_group(grp, parent)
        return create_dataset(subgroup, pname,
                              shape=shape, dtype=dtype, data=data, fillvalue=fillvalue)
    end

    _assert_valid_name(name, grp)

    if isnothing(data) && isnothing(shape)
        throw(ArgumentError("Cannot create dataset. Missing shape or data keyword."))
    end

    (prepared_data, attrs, meta) = _prepare_write(
        data,
        Dict(),
        defaultmetadata(DATASET_TYPENAME)
    )

    _assert_data_shape_dtype_match(prepared_data, shape, dtype)

    (shape, dtype) = _data_to_shape_and_dtype(prepared_data, shape, dtype)

    if !isnothing(prepared_data)
        if !isnothing(shape) && (size(prepared_data) != shape)
            prepared_data = reshape(prepared_data, shape)
        end
    else
        if isnothing(shape)
            prepared_data = nothing
        else
            if isnothing(fillvalue)
                fillvalue = 0.0
            end
            prepared_data = fill(dtype(fillvalue), shape)
        end
    end

    if isnothing(prepared_data)
        error("Could not create a meaningful dataset.")
    end

    create_object_directory(joinpath(grp.directory, name), meta)

    dataset = Dataset(
        root_directory = grp.root_directory,
        parent_path = grp.relative_path,
        object_name = name,
        file = grp.file,
        data = prepared_data
    )
    # dataset._reset_data(prepared_data, attrs, None)  # meta already set above
    dataset
end

function require_dataset(grp::AbstractGroup, name::AbstractString;
                         shape=nothing,
                         dtype=nothing,
                         exact::Bool=false,
                         data=nothing,
                         fillvalue=nothing)
    assert_file_open(grp.file)
    if !in(name, grp)
        return create_dataset(grp, name,
                              shape=shape, dtype=dtype, exact=exact, data=data, fillvalue=fillvalue)
    end

    current_object = grp[name]

    if !isa(current_object, Dataset)
        throw(
            TypeError(
                :require_dataset,
                "Incompatible object already exists",
                Dataset,
                typeof(current_object)
            )
        )
    end

    (data, attrs, meta) = _prepare_write(data, Dict(), Dict())

    # TODO verify proper attributes

    _assert_data_shape_dtype_match(data, shape, dtype)
    (shape, dtype) = _data_to_shape_and_dtype(data, shape, dtype)

    shape_exist = size(current_object)
    if shape != shape_exist
        throw(
            DimensionMismatch(
                "Shapes do not match: existing $(shape_exist) vs. new $(shape)"
            )
        )
    end

    dtype_exist = eltype(current_object)
    if dtype != dtype_exist
        if exact
            throw(
                TypeError(
                    :require_dataset,
                    "Datatypes do not exactly match",
                    dtype_exist,
                    dtype
                )
            )
            # if not np.can_cast(dtype, current_object.dtype):
            #     raise TypeError(
            #         "Cannot safely cast from {} to {}".format(
            #             dtype,
            #             current_object.dtype
            #         )
            #     )
        end
    end

    current_object
end

function root_directory(path::AbstractString)
    # https://github.com/CINPLA/exdir/blob/89c1d34a5ce65fefc09b6fe1c5e8fef68c494e75/exdir/core/exdir_object.py#L128
    path = realpath(path)
    found = false
    while !found
        (parent, pname) = splitdir(path)
        if parent == path
            return nothing
        end
        if !is_nonraw_object_directory(path)
            path = parent
            continue
        end
        meta_data = YAML.load_file(joinpath(path, META_FILENAME))
        if !haskey(meta_data, EXDIR_METANAME)
            path = parent
            continue
        end
        exdir_meta = meta_data[EXDIR_METANAME]
        if !haskey(exdir_meta, TYPE_METANAME)
            path = parent
            continue
        end
        if FILE_TYPENAME != exdir_meta[TYPE_METANAME]
            path = parent
            continue
        end
        found = true
    end
    path
end

function is_inside_exdir(path::AbstractString)
    # https://github.com/CINPLA/exdir/blob/89c1d34a5ce65fefc09b6fe1c5e8fef68c494e75/exdir/core/exdir_object.py#L161
    path = realpath(path)
    !isnothing(root_directory(path))
end

function assert_inside_exdir(path::AbstractString)
    # https://github.com/CINPLA/exdir/blob/89c1d34a5ce65fefc09b6fe1c5e8fef68c494e75/exdir/core/exdir_object.py#L166
    if !is_inside_exdir(path)
        error("Path " + path + " is not inside an Exdir repository.")
    end
end

function open_object(directory::AbstractString)
    # https://github.com/CINPLA/exdir/blob/89c1d34a5ce65fefc09b6fe1c5e8fef68c494e75/exdir/core/exdir_object.py#L172
    path = realpath(directory)
    assert_inside_exdir(path)
end

function is_nonraw_object_directory(directory::AbstractString)
    meta_filename = joinpath(directory, META_FILENAME)
    if !ispath(meta_filename) && !isfile(meta_filename)
        return false
    end
    meta_data = YAML.load_file(meta_filename)
    # TODO is not instance of dict return false
    if !haskey(meta_data, EXDIR_METANAME)
        return false
    end
    if !haskey(meta_data[EXDIR_METANAME], TYPE_METANAME)
        return false
    end
    valid_types = [DATASET_TYPENAME, FILE_TYPENAME, GROUP_TYPENAME]
    if !(meta_data[EXDIR_METANAME][TYPE_METANAME] in valid_types)
        return false
    end
    true
end

"""
WARNING: Does not test of inside exdir directory,
only if the object can be an exdir object (i.e. a directory).
"""
function is_exdir_object(directory)
    isdir(directory)
end

function is_raw_object_directory(directory::AbstractString)
    is_exdir_object(directory) && !is_nonraw_object_directory(directory)
end

"""
    create_object_directory(directory, metadata)

Create object directory and meta file if the directory doesn't already exist.

TODO say something about expected correctness of metadata dict.
"""
function create_object_directory(directory::AbstractString, metadata)
    if ispath(directory)
        throw(ArgumentError("The location '$directory' already exists"))
    end
    valid_types = [DATASET_TYPENAME, FILE_TYPENAME, GROUP_TYPENAME]
    typename = metadata[EXDIR_METANAME][TYPE_METANAME]
    if !(typename in valid_types)
        error("$typename is not a valid typename")
    end
    mkdir(directory)
    YAML.write_file(joinpath(directory, META_FILENAME), metadata)
    nothing
end

function _assert_valid_name(name::AbstractString, container)
    # container.file.name_validation(container.directory, name)
end

function _dataset(grp::AbstractGroup, name::AbstractString)
    Dataset(
        root_directory = grp.root_directory,
        parent_path = grp.relative_path,
        object_name = name,
        file = grp.file,
    )
end

end
