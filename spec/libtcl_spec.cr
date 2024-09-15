require "./spec_helper"

describe "LibTcl" do
  it "evaluates tcl code and produces results" do
    interp = LibTcl.create_interp
    LibTcl.init(interp)
    result = LibTcl.eval(interp, "set a 1")
    result.should eq(LibTcl::Result::Ok)
    rstrptr = LibTcl.get_string_result(interp)
    String.new(rstrptr).should eq "1"
    result = LibTcl.eval(interp, "puts $b")
    result.should eq(LibTcl::Result::Error)
  end
end
