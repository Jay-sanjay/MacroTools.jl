using MacroTools: flatten, striplines


@testset "flatten try" begin # see julia#50710 and MacroTools#194
    exs = [
        quote try; f(); catch; end; end,
        quote try; f(); catch; else; finally; end; end,
        quote try; f(); catch E; else; finally; end; end,
        quote try; f(); catch; finally; end; end,
        quote try; f(); catch E; finally; end; end,
        quote try; f(); catch E; 3+3; finally; 4+4; end; end,
        quote try; f(); catch E; 3+3; else; 2+2; finally; 4+4; end; end,
        quote try; f(); finally; end; end,
        quote try; f(); catch; false; finally; end; end,
        quote try; f(); catch; else; finally; false; end; end,
        quote try; f(); catch; else; end; end,
        quote try; f(); catch; 3+3; else; 2+2; end; end,
        quote try; f(); catch E; else; end; end,
        quote try; f(); catch E; 3+3; else; 2+2; end; end
    ]
    for ex in exs
        #@show ex
        @test flatten(ex) |> striplines == ex |> striplines
        @test flatten(striplines(ex)) == striplines(ex).args[1]
    end
    @test 123 == eval(flatten(striplines(:(try error() catch; 123 finally end))))
    @test 123 == eval(flatten(:(try error() catch; 123 finally end)))
    @test 234 == eval(flatten(striplines(:(try 1+1 catch; false; else 234; finally end))))
    @test 234 == eval(flatten(:(try 1+1 catch; false; else 234; finally end)))
    for (exa, exb) in [
        (quote try; begin f(); g(); end; catch; end; end,                               quote try; f(); g(); catch; end; end),
        (quote try; catch; begin f(); g(); end;  end; end,                              quote try; catch; f(); g(); end; end),
        (quote try; begin f(); g(); end; catch; finally; begin m(); n(); end; end; end, quote try; f(); g(); catch; finally; m(); n(); end; end)
    ]
        @test exa |> flatten |> striplines == exb |> striplines
        @test exa |> striplines |> flatten == (exb |> striplines).args[1]
    end
end
