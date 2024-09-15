require "./libtcl"

# an inefficient recursive fibonacci function
def fibz(n : Int64)
  return 0  if n <= 0
  return 1  if n == 1
  fibz(n-1) + fibz(n-2)
end

module TclCrystalExample
  VERSION = "0.0.1"

  puts "Starting Tcl intepreter"
  interp = LibTcl.create_interp()
  LibTcl.init(interp)
  
  # set and get/puts some variables
  LibTcl.eval(interp, "set a 1")
  LibTcl.eval(interp, "puts $a")
  
  # same interpreter, so variables will be persistent
  LibTcl.eval(interp, "set a 2")
  status = LibTcl.eval(interp, "puts $a")
  puts status

  # try to print an unknown var which is an error.
  # this will set status to LibTcl::Result::Error and can access 
  # the string of the error using get_string_result
  status = LibTcl.eval(interp, "puts $b")
  puts status
  result = LibTcl.get_string_result(interp)
  puts String.new(result)

  # we can still reuse the interpreter after it errored.
  status = LibTcl.eval(interp, "puts $a")
  puts status
  

  # define a function in crystal-space that we can register with a Tcl interpreter
  myfunc = ->(client_data : LibTcl::ClientData, interp : Pointer(LibTcl::Interp), argc : LibC::Int, argv : LibTcl::Argv) {
    puts "myfunc argc = #{argc}"
    argc.times do |n|
      ss = String.new(argv[n])
      puts "  argv#{n} = #{ss}"
    end
    return LibTcl::Result::Ok
  }

  fib = ->(client_data : LibTcl::ClientData, interp : Pointer(LibTcl::Interp), argc : LibC::Int, argv : LibTcl::Argv) {
    if argc != 2 
      return LibTcl::Result::Error
    end
    n = String.new(argv[1]).to_i
    f = fibz(n)
    str_result = f.to_s
    LibTcl.set_var2(interp, "env", "fibval", "done", LibTcl::VarFlags::GlobalOnly)
    LibTcl.set_result(interp, str_result, nil)
    return LibTcl::Result::Ok
    
  } 
  
  # register the function
  LibTcl.create_command(interp, "myfunc", myfunc, nil, nil)
  # evaluating the function with different args.
  LibTcl.eval(interp, "myfunc")
  LibTcl.eval(interp, "myfunc 7")
  LibTcl.eval(interp, "myfunc 7 8")
  
  # register the fibonacci function that returns a value
  LibTcl.create_command(interp, "fib", fib, nil, nil)
  LibTcl.eval(interp, "set n 14")
  LibTcl.eval(interp, "set f [fib $n]")
  LibTcl.eval(interp, "puts \"fibonacci of $n is $f\"")
  LibTcl.eval(interp, "puts \"fibenv $env(fibval)\"")

  
end
