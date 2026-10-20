using ArgParse

function parse_commandline()
    s = ArgParseSettings()
    @add_arg_table s begin
        "--verbose", "-v"
        help = "show additional information"
        action = :store_true
        "--opt1", "-o"
        help = "option one is an integer"
        arg_type = Int
        default = 0
        "--opt2", "-s"
        help = "this is a string option"
        arg_type = String
        default = ""
        "arg1"
        help = "first positional argument"
        required = true
    end
    return parse_args(s)
end

function main()
    parsed_args = parse_commandline()
    println("Parsed args:")
    for (arg,val) in parsed_args
        println("  $arg  =>  $val")
    end
end

main()