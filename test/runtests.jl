using OrthancTools
using Test
using OrderedCollections
using HTTP
using JSON

#=
To run the tests locally with the Orthanc server, use:
```
julia --project -e 'using Pkg; Pkg.test("OrthancTools", test_args=["local"])'
```

Else, run the tests in CI with:
```
julia --project -e 'using Pkg; Pkg.test("OrthancTools")'
```
Or simply:
```
(OrthancTools) pkg> test
```
=#

# Check if we're running local tests
TEST_MODE = filter(x -> x in ["local"], ARGS)
if isempty(TEST_MODE)
    @info "Running CI tests (no server connection)"
else
    @info "Running local tests with Orthanc server"
end

# Constants for local testing
const TEST_IP = "128.200.49.26"
const TEST_ACCESSION = "2581"
const TEST_SERIES = "1"

@testset "OrthancTools.jl" begin
    if "local" in TEST_MODE
        @testset "Local tests with real server" begin
            # Test getting studies
            studies_dict = get_all_studies(TEST_IP)
            @test studies_dict isa OrderedDict
            @test !isempty(studies_dict)
            
            # Test getting series
            series_dict = get_all_series(studies_dict, TEST_ACCESSION, TEST_IP)
            @test series_dict isa OrderedDict
            @test !isempty(series_dict)
            
            # Test getting instances
            instances_dict = get_all_instances(series_dict, TEST_SERIES, TEST_IP)
            @test instances_dict isa OrderedDict
            @test !isempty(instances_dict)
            
            # Test downloading instances
            temp_dir = mktempdir()
            try
                download_instances(instances_dict, 1, temp_dir, TEST_IP)
                # Check if any DICOM files were downloaded
                @test !isempty(readdir(temp_dir))
                @test any(endswith.(readdir(temp_dir), ".dcm"))
            finally
                rm(temp_dir, recursive=true)
            end
        end
    else
        @testset "CI verification tests" begin
            # Test type stability and basic functionality
            @testset "get_all_studies" begin
                # Test that it throws the right error for non-existent server
                @test_throws HTTP.ConnectError get_all_studies("localhost", show_warnings=true)
                
                # Test return type with mock data
                studies_dict = OrderedDict{String,Vector}()
                @test studies_dict isa OrderedDict{String,Vector}
            end

            @testset "get_all_series" begin
                # Test that it throws the right error for non-existent server
                studies_dict = OrderedDict("ACC001" => ["study1"])
                @test_throws HTTP.ConnectError get_all_series(studies_dict, "ACC001", "localhost")
                
                # Test input validation
                @test_throws KeyError get_all_series(OrderedDict{String,Vector}(), "nonexistent", "localhost")
            end

            @testset "get_all_instances" begin
                # Test that it throws the right error for non-existent server
                series_dict = OrderedDict("1" => ["series1"])
                @test_throws HTTP.ConnectError get_all_instances(series_dict, "1", "localhost")
                
                # Test input validation
                @test_throws KeyError get_all_instances(OrderedDict{String,Vector}(), "nonexistent", "localhost")
            end

            @testset "download_instances" begin
                temp_dir = mktempdir()
                try
                    instances_dict = OrderedDict("1" => [["instance1"]])
                    # Test that it throws the right error for non-existent server
                    @test_throws HTTP.ConnectError download_instances(instances_dict, 1, temp_dir, "localhost")
                finally
                    rm(temp_dir, recursive=true)
                end
            end
        end
    end
end
