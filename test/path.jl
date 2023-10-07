using Test

import Exdir:
    clean_path,
    name_to_asserted_group_path,
    remove_root,
    form_relative_path

@testset "path" begin
    @testset "clean_path" begin
        @test clean_path("/hello") == "/hello"
        @test clean_path("/hello/") == "/hello"
        @test clean_path("/hello///////") == "/hello"
        @test clean_path("/hello////world///") == "/hello/world"
        @test clean_path("./hello////world///") == "hello/world"
    end

    # @testset "name_to_asserted_group_path" begin

    # end

    @testset "remove_root" begin
        @test remove_root("hello") == "hello"
        @test remove_root("/hello") == "hello"
        @test remove_root("///hello") == "hello"
    end

    @testset "form_relative_path" begin
        @test form_relative_path(".", "citrus") == "citrus"
        @test form_relative_path("./citrus", "") == "citrus"
        @test form_relative_path("citrus", "lemon") == "citrus/lemon"
        @test form_relative_path("./citrus", "lemon") == "citrus/lemon"
        @test form_relative_path("./citrus", "lemon/") == "citrus/lemon"
        @test form_relative_path("./citrus", "lemon/meyer/") == "citrus/lemon/meyer"
        @test form_relative_path(".", "") == ""
        @test form_relative_path("./", "") == ""
    end
end
