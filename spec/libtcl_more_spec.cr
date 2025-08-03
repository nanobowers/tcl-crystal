require "./spec_helper"
require "../src/libtcl"

describe "LibTcl" do
  # This pointer will be managed by the before_each/after_each hooks
  interp : LibTcl::Interp* = Pointer(LibTcl::Interp).malloc(1)

  before_each do
    interp = LibTcl.create_interp
    interp.should_not be_nil
    # Initialize the interpreter to have access to standard commands
    init_result = LibTcl.init(interp)
    init_result.should eq(LibTcl::Result::Ok)
  end

  after_each do
    LibTcl.delete_interp(interp) unless interp.null?
  end

  describe "Interpreter & String API" do
    it "evaluates a simple script and returns Ok" do
      script = "set a 42"
      result = LibTcl.eval(interp, script)
      result.should eq(LibTcl::Result::Ok)
    end

    it "gets a string result from an evaluation" do
      script = "return {Hello, Crystal!}"
      LibTcl.eval(interp, script) # eval will return Result::Return
      result_str = String.new(LibTcl.get_string_result(interp))
      result_str.should eq("Hello, Crystal!")
    end

    it "sets and gets a variable using the string API" do
      var_name = "myvar"
      var_value = "myvalue"
      flags = LibTcl::VarFlags::None

      # Set the variable
      LibTcl.set_var(interp, var_name, var_value, flags)

      # Get the variable and verify its value
      retrieved_value_ptr = LibTcl.get_var(interp, var_name, flags)
      retrieved_value_ptr.should_not be_nil
      String.new(retrieved_value_ptr).should eq(var_value)
    end

    it "creates and calls a custom string-based command" do
      # This Crystal proc will be the implementation of our Tcl command.
      # It sets the Tcl result to a static string.
      crystal_command_proc = ->(client_data : LibTcl::ClientData, interp_ptr : LibTcl::Interp*, argc : LibC::Int, argv : LibTcl::Argv) do
        # The result is a static string, so Tcl should not try to free it.
        # We pass a no-op free proc.
        static_result = "Hello from a Crystal command!"
        no_op_free = ->(p : Void*) {}
        LibTcl.set_result(interp_ptr, static_result, no_op_free)
        LibTcl::Result::Ok
      end

      # Register the command
      command_name = "crystal_cmd"
      LibTcl.create_command(interp, command_name, crystal_command_proc, nil, nil)

      # Evaluate a script that calls our new command
      script = "crystal_cmd"
      result = LibTcl.eval(interp, script)
      result.should eq(LibTcl::Result::Ok)

      # Check the result set by our proc
      result_str = String.new(LibTcl.get_string_result(interp))
      result_str.should eq("Hello from a Crystal command!")
    end
  end


  describe "Object API" do
    it "creates a string object and retrieves its value" do
      crystal_string = "Tcl Object"
      # Create a Tcl_Obj from a Crystal string
      tcl_obj = LibTcl.new_string_obj(crystal_string, crystal_string.bytesize)
      tcl_obj.should_not be_nil

      # Get the string back from the object
      len_ptr = Pointer(LibC::Int).malloc(1)
      c_str = LibTcl.get_string_from_obj(tcl_obj, len_ptr)
      retrieved_string = String.new(c_str, len_ptr.value)
      retrieved_string.should eq(crystal_string)
    end

    it "evaluates a script using an array of Tcl_Obj" do
      # We will evaluate the script: `set b 99`
      set_obj = LibTcl.new_string_obj("set", -1)
      var_obj = LibTcl.new_string_obj("b", -1)
      val_obj = LibTcl.new_string_obj("99", -1)

      # The object array must be manually managed
      objv = Pointer(LibTcl::Obj*).malloc(3)
      objv[0] = set_obj
      objv[1] = var_obj
      objv[2] = val_obj

      # Evaluate the object array
      result = LibTcl.eval_objv(interp, 3, objv, 0)
      result.should eq(LibTcl::Result::Ok)

      # Verify the result by getting the object result
      result_obj = LibTcl.get_obj_result(interp)
      len_ptr = Pointer(LibC::Int).malloc(1)
      result_str = String.new(LibTcl.get_string_from_obj(result_obj, len_ptr))
      result_str.should eq("99")

    end
  end

end
