@enum OpenMode begin
    READ_WRITE
    READ_ONLY
    FILE_CLOSED
end

function assert_file_open(file_object)
    # if file_object.io_mode == OpenMode.FILE_CLOSED
    #     throw(IOError("Unable to operate on closed File instance."))
    # end
    nothing
end

function assert_file_writable(file_object)
    # assert_file_open(file_object)
    # if file_object.io_mode == OpenMode.READ_ONLY
    #     throw(IOError("Cannot change data on file in read only 'r' mode"))
    # end
    nothing
end
