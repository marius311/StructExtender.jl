
using CompositeStructs, Test

@testset "CompositeStructs" begin

    # tests work by explicilty redefing the @composite structs, which
    # will be an error if its not exactly the same
        
    # docstring example
    @test_nowarn @eval module $(gensym())
        using CompositeStructs
        struct Foo{X,Y}
            x :: X
            y :: Y
        end
        @composite struct Bar{X,Y,Z}
            Foo{X,Y}...
            z :: Z
        end
        struct Bar{X,Y,Z}
            x :: X
            y :: Y
            z :: Z
        end
    end

    # composite type in Foo, swap Y/X
    @test_nowarn @eval module $(gensym())
        using CompositeStructs
        struct Foo{X<:Real,Y}
            x :: X
            y :: Complex{Y}
        end
        @composite struct Bar{X,Y,Z}
            Foo{Y,X}...
            z :: Z
        end
        struct Bar{X,Y,Z}
            x :: Y
            y :: Complex{X}
            z :: Z
        end
    end

    # multiple splices / order
    @test_nowarn @eval module $(gensym())
        using CompositeStructs
        struct X x end
        struct Z z end
        @composite struct Bar
            X...
            y
            Z...
        end
        struct Bar
            x
            y
            z
        end
    end

    # non-concrete field
    @test_nowarn @eval module $(gensym())
        using CompositeStructs
        struct Foo{T}
            x :: Array{T,N} where {N}
        end
        @composite struct Bar{T}
            Foo{T}...
            y
        end
        struct Bar{T}
            x :: Array{T,N} where {N}
            y
        end
    end


    # mutable structs, with supertype
    @test_nowarn @eval module $(gensym())
        using CompositeStructs
        mutable struct Foo <: Real
            x
        end
        @composite mutable struct Bar <: Number
            Foo...
            y
        end
        mutable struct Bar <: Number
            x
            y
        end
    end

    # kwdef
    @test_nowarn @eval module $(gensym())
        using CompositeStructs, Test

        Base.@kwdef struct Child1{T} <: Real
            x::T = 1
        end
        
        Base.@kwdef struct Child2
            y
        end

        @composite Base.@kwdef struct ParentInner{T} <: Number
            Child1{T}...
            Child2...
            z = 3
            w
        end
        
        @test ParentInner(y=2, w=4) == ParentInner{Int64}(1,2,3,4)
        @test ParentInner{Float64}(y=2, w=4) == ParentInner{Float64}(1.0,2,3,4)
        @test ParentInner(x="x", y="y", z="z", w="w") == ParentInner{String}("x", "y", "z", "w")

        Base.@kwdef @composite struct ParentOuter{T} <: Number
            Child1{T}...
            Child2...
            z = 3
            w
        end
        
        @test ParentOuter(x=1, y=2, w=4) == ParentOuter{Int64}(1,2,3,4)

    end
    
end


